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
  key_name   = local.name
  public_key = tls_private_key.this.public_key_openssh
}

#  ┬─┐┌─┐┌─┐
#  ├─ │  ┌─┘
#  ┴─┘└─┘└──

module "ec2_manager" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "< 6.0.0"

  name                        = "${local.name}-manager"
  instance_type               = "t4g.medium"
  ami                         = data.aws_ami.ubuntu.image_id
  ignore_ami_changes          = true
  disable_api_termination     = true
  associate_public_ip_address = true
  create_eip                  = true

  metadata_options = {
    http_endpoint               = "enabled",
    http_put_response_hop_limit = 1,
    http_tokens                 = "required"
  }

  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = compact([
    aws_security_group.egress.id,
    aws_security_group.intranet.id,
    try(aws_security_group.admin[0].id, ""),
  ])

  iam_instance_profile = aws_iam_instance_profile.manager.name
  key_name             = aws_key_pair.this.key_name
  monitoring           = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 125
      volume_size = 10
      tags        = { Name = "${local.name}-manager-root" }
    }
  ]

  user_data_replace_on_change = true
  user_data                   = local.manager_user_data

  enable_volume_tags = false
}

resource "null_resource" "wait_for_manager_cluster" {
  triggers = {
    manager_instance_id = module.ec2_manager.id
  }

  connection {
    type        = "ssh"
    host        = module.ec2_manager.public_ip
    port        = 22
    user        = "ubuntu"
    private_key = tls_private_key.this.private_key_openssh
  }

  provisioner "remote-exec" {
    inline = [<<-EOF
      export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
      while [ ! -f /initialized ]; do
        echo "info: Waiting for initialization to finish"
        sleep 5
      done
      echo "info: Bootstrap is done"
    EOF
    ]
  }
}

#  ┐─┐┐─┐┌┌┐
#  └─┐└─┐│││
#  ──┘──┘┘ ┘

resource "aws_ssm_parameter" "manager_kubeconfig" {
  type        = "SecureString"
  name        = local.manager_kubeconfig_ssm_parameter
  description = "Manager cluster kubeconfig in the ${local.name} tenant"
  value       = "will be replaced by cloudinit user data from manager instance"

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "manager_kubeconfig" {
  name = local.manager_kubeconfig_ssm_parameter

  depends_on = [
    null_resource.wait_for_manager_cluster
  ]
}

resource "local_sensitive_file" "kubeconfig" {
  filename        = "${path.module}/kubeconfig.yaml"
  content         = data.aws_ssm_parameter.manager_kubeconfig.value
  file_permission = "0600"
}
