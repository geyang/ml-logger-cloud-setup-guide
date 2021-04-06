n_workers = 1
// this is the region-specific pem certificate
aws_key_pair_name = "ge-improbable-aws-west-2"
//logging_instance_type = "c4.large"
logging_instance_type = "c6g.large"
// =================== DO NOT CHANGE ABOVE ======================
region = "us-west-2"
logging_availability_zone = "us-west-2b"
instrument_amis = {
  // do NOT change this. This is instrument server.
  "us-west-2" = "ami-0ad267d127a061b59"
}
amis = {
  "us-west-2" = "ami-a4a1dadc"
}
security_key_name = "instrumentation-server"
iam_role_name = "ge-improbable"
bucket_name = "ge-improbable"
