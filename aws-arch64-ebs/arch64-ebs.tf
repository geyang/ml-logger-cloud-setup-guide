variable "n_workers" {
  default = 0
}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_private_key_path" {}
variable "aws_key_pair_name" {}
variable "logging_instance_type" {}
variable "security_key_name" {}
variable region {}
// by defining this statically, we can keep the ebs volume persistent.
// Otherwise we have to read the AZ from the logging server, changing the AZ on each launch.
variable "logging_availability_zone" {}
variable "iam_role_name" {}
variable "bucket_name" {}
variable instrument_amis {
  type = map(string)
}
variable amis {
  type = map(string)
}
variable username {
  default = "ec2-user"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.region
}

resource "aws_iam_role" "main" {
  name = var.iam_role_name
  assume_role_policy = file("iam-role-policy.json")
}

resource "aws_iam_policy" "main" {
  name = "ec2-s3-policy"
  description = "A test policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [ "s3:*" ],
        "Resource": [ "*" ]
      },
      {
        "Effect": "Allow",
        "Action": [ "ec2:TerminateInstances", "ec2:CreateTags" ],
        "Resource": [ "*" ]
      },
      {
        "Effect": "Allow",
        "Action": [
            "tag:getResources",
            "tag:getTagKeys",
            "tag:getTagValues",
            "tag:TagResources",
            "tag:UntagResources"
        ],
        "Resource": "*"
      }
    ]
}
EOF
}

// this one just allows the instance to assume role when spun up.
resource "aws_iam_role_policy_attachment" "main-attach" {
  role = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

// this is where you specify the role.
resource "aws_iam_instance_profile" "main" {
  name = "main"
  role = aws_iam_role.main.name
}

resource "aws_security_group" "security_key" {
  name = var.security_key_name
  description = "Gym instance inoutbound rules"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 4544
    to_port = 4545
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 445
    to_port = 445
    protocol = "tcp"
    description = "samba drive port"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 1024
    to_port = 5000
    protocol = "tcp"
    description = "samba drive dynamic RPC"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_eip" "instrument_ip" {
  count = 1
  instance = element(aws_instance.logging-server.*.id, count.index)
  provisioner "local-exec" {
    command = "echo \"${aws_eip.instrument_ip.0.public_ip}\" > instrument_ip_address.txt"
  }
}

# Create an EBS to contains "flux" directory used by FTP
resource "aws_ebs_volume" "runs-data" {
  depends_on = [
    aws_instance.logging-server]
  availability_zone = var.logging_availability_zone
  //"${aws_instance.logging-server.availability_zone}"
  // for volume type see here: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html
  type = "gp2"
  size = "100"
  tags = {
    Name = "runs-data"
  }
}

resource "aws_volume_attachment" "instrument-data-volume-attachment" {
  depends_on = [
    aws_ebs_volume.runs-data]
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.runs-data.id
  instance_id = aws_instance.logging-server.id
  skip_destroy = true
}

resource "aws_instance" "logging-server" {
  tags = {
    Name = "Instrument Server"
  }
  // count = 1
  // termination protection!! Not the first time I killed this accidentally :(
  disable_api_termination = false
  ami = lookup(var.instrument_amis, var.region)
  availability_zone = var.logging_availability_zone
  //"${aws_instance.logging-server.availability_zone}"
  instance_type = var.logging_instance_type
  key_name = var.aws_key_pair_name
  security_groups = [
    aws_security_group.security_key.name
  ]
  iam_instance_profile = aws_iam_instance_profile.main.name
//  # Run the attach_ebs.sh file as part of startup
//  user_data = file("scripts/mount-ebs.sh")
  root_block_device {
    volume_size = 20
  }
  connection {
    user = var.username
    private_key = file(var.aws_private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source = "home/"
    destination = "/home/${var.username}/"
  }
  provisioner "remote-exec" {
    inline = [
      "mkfs -t ext4 /dev/sdh",
      "mkdir ~/runs",
      "sudo mount /dev/sdh ~/runs",
      "bash startup.sh",
    ]
  }
}
