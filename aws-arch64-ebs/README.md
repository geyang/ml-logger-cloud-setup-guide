# Setup Guide

This terraform reciepie will enable you to setup a low-cost arm-based instance on AWS without much manual work.

## Security

**NOTE: It is extremely important to make sure that you do not commit your AWS/GCE access information to a public gist or git repository. This is because all GitHub public repo/gists are crawled by bots on a daily basis, and bad guy and gals will abuse your account. Folks have been fired because of this.**

 

## Setting up AWS Key Pairs

To launch `ec2` instances you need to create key pairs. Key pairs are specific to each availability zone, which is why `doodad` post-fixes the name of each key pair with the zone name. For detailed guide take a look at the [aws documentation on key pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws). 

> **Important**: Make sure you call `sudo chown 400 $HOME/.aws/ge-<your-team>-west-2.pem` so that the permission is okay

Now, you want to supply your aws profile information in a `secret.auto.tfvars` file

```yaml
#! secrete.auto.tfvars
aws_access_key = "SOMELONGKEYTHATLOOKS"
aws_secret_key = "soMeLonGKeYtHAtlookSLiketHis+so"
aws_private_key_path = "/Users/<your-username>/.aws/ge-<your-team>-west-2.pem"
```

Then also change the profile settings in the `config.auto.tfvars` file

```yaml
aws_key_pair_name = "ge-<your-team>-aws-west-2"
security_key_name = "instrumentation-server"
iam_role_name = "ge-<your-team>"
bucket_name = "ge-<your-team>"
```

Note that I assume we are launching in the `west-2` availability zone. So your key pair needs to be created there.

## Launching the Instance

First we need to install the terraform dependencies.

```bash
terraform init
```

If you have not touched this for a while and terraform version has changed, you can update all terraform providers via

```bash
terraform init --reconfigure
```

 

When the providers are all installed correctly you can now launch the instance.

```bash
yes yes | terraform apply
```

If you run into errors, please create an issue in this repo.



## SSH into the Instance

We include the command in the [Makefile](./Makefile): `make ssh-instrument`

```bash
ssh ec2-user@`< instrument_ip_address.txt` -i $HOME/.aws/ge-<your-team>-west-2.pem
```

will allow you to connect to the instance. We set the firewall of this instance to be fairly open, but if you are concerned about safety you can change those configurations in the terraform file.



## Installing and Setting up ML-Logger

- **Mounting the EBS Volume**  The `ebs` volume is not mounted automatically on instance start. You need to mount it manually, or add these lines of code to the terraform execution script. 

  For details of how to set it up, take a look at https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html.

  ```bash
  lsblk
  rm -rf runs
  sudo mkfs -t xfs /dev/nvme1n1
  mkdir runs
  sudo mount /dev/nvme1n1 $HOME/runs
  df -h
  sudo chown $USER -R ~/runs
  ```

  make sure that you change the ownership to `$USER`, otherwise you are going to get `FilePermissionError` during logging.

- **Installing `ArchiConda`**  ArchiConda is an Anaconda distribution for the arm architecture (aarch64 platform). 

  ```bash
  wget https://github.com/Archiconda/build-tools/releases/download/0.2.3/Archiconda3-0.2.3-Linux-aarch64.sh
  #chmod +x Archiconda3-0.2.3-Linux-aarch64.sh
  bash Archiconda3-0.2.3-Linux-aarch64.sh -b -p $HOME/archiconda
  #echo ". /home/ec2-user/archiconda/etc/profile.d/conda.sh" >> ~/.bashrc
  sudo ln -s /home/ec2-user/archiconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
  source /etc/profile.d/conda.sh
  ```

  What this does is that it symbolic links the conda script to all users (as opposed to yourself) in the system. 

- **Updating the Conda `base` Environment with Dependencies**  It is not entirely clear if this is necessary since I ended up still had to setup the dependencies for `ml-dash` manually. 

  There is a file  

- **Installing `pyCUrl`**  Because this instance is on the `aarch64` platform, directly installing via conda is not going to work. `puCUrl` is only used by the `ml-logger` logging client, so technically it will not be needed.

  Before installing pyCurl, try to install the required system dependencies

  ```bash
  sudo yum install libcurl-devel.aarch64
  sudo yum install python-devel.aarch64
  sudo yum install openssl-devel.aarch64
  ```

  To install `pyCUrl` from source: First compile, and then run `setup.py install`.

  ```bash
  git clone https://github.com/pycurl/pycurl.git
  cd pycurl
  make
  python setup.py install
  ```

  

- **Installing ML-Dash Dependencies**: The modules have to be in the following versions

  ```yaml
  - graphene=2.1.8
  - graphql-core=2.3.2
  - graphql-relay=2.0.1
  - graphql-server=3.0.0b2
  - graphql-server-core=2.0.0
  - sanic=18.12.0
  - Sanic-GraphQL=1.2.0
  - Sanic-Cors=0.10.0.post3
  ```

  `pillow` would fail during conda install. So you need the system version. The development package contains c-headers.

  ```bash
  sudo yum install python-pillow-devel.aarch64 python-pillow.aarch64
  ```



## Mantainance During Production

- **Increasing the EBS Volume** It is very difficult to "shrink" the volume of an EBS drive, but it is super easy to expand it.

  1. First change the volume inside the EC2 console.
  2. Now update the size registration in the OS

  ```bash
  sudo resize2fs /dev/nvme1n1
  ```

  