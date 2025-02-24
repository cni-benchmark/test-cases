#  ┌┌┐┬─┐o┌┐┐
#  ││││─┤││││
#  ┘ ┘┘ ┘┘┘└┘

#  ┌┐┐┬  ┐─┐
#   │ │  └─┐
#   ┘ ┘─┘──┘

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = var.name
  public_key = tls_private_key.this.public_key_openssh
}

#  ┬─┐┌─┐┌─┐
#  ├─ │  ┌─┘
#  ┴─┘└─┘└──

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "<6.0.0"

  name                        = var.name
  instance_type               = var.instance_type
  ami                         = var.ami
  ignore_ami_changes          = true
  disable_api_termination     = false
  associate_public_ip_address = var.associate_public_ip_address

  metadata_options = {
    http_endpoint               = "enabled",
    http_put_response_hop_limit = 1,
    http_tokens                 = "required"
  }

  subnet_id              = var.vpc_subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  iam_instance_profile = var.iam_instance_profile
  key_name             = aws_key_pair.this.key_name
  monitoring           = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 125
      volume_size = var.root_size
      tags        = { Name = "${var.name}-root" }
    }
  ]

  user_data_replace_on_change = true
  user_data                   = var.user_data

  enable_volume_tags = false
}
