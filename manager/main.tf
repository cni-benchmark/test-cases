#  ┌┌┐┬─┐o┌┐┐
#  ││││─┤││││
#  ┘ ┘┘ ┘┘┘└┘

locals {
  name              = var.tenant
  azs               = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_cidr_block    = var.vpc_cidr_block
  vpc_cidr_netmask  = split("/", local.vpc_cidr_block)[1]
  manager_user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail
    
    echo "root:root" | chpasswd
    while lsof /var/lib/dpkg/lock || lsof /var/lib/dpkg/lock-frontend; do
      echo "Waiting for dpkg locks to be released..."
      sleep 2
    done
    export DEBIAN_FRONTEND=noninteractive    
    apt-get update -qqy
    apt-get install -qqy zsh python3-pip git vim acl
    python3 -m pip install --upgrade ranger-fm --break-system-packages
    usermod -s "$(which zsh)" ubuntu
    usermod -s "$(which zsh)" root
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /opt/powerlevel10k
    echo 'source /opt/powerlevel10k/powerlevel10k.zsh-theme' | tee -a ~{root,ubuntu}/.zshrc
    
    arch="$(uname -m | sed -r 's/aarch/arm/g; s/x86_/amd/g')"
    curl -fsSLo /tmp/k9s.deb "https://github.com/derailed/k9s/releases/latest/download/k9s_linux_$arch.deb"
    dpkg -i /tmp/k9s.deb || true
    apt-get install -qqy -f

    curl -fsSL https://get.k3s.io | bash
    cat <<EOT | tee -a ~{root,ubuntu}/{.zshrc,.bashrc}
    alias kubectl="k3s kubectl"
    alias k="kubectl"
    alias kg="kubectl get"
    alias ky="kubectl get -o yaml"
    alias kubens="kubectl config set-context --current --namespace"
    EOT
    setfacl -Rm u:ubuntu:rwx /etc/rancher
    setfacl -dRm u:ubuntu:rwx /etc/rancher
    mkdir -p ~{root,ubuntu}/.kube
    ln -fs /etc/rancher/k3s/k3s.yaml ~root/.kube/config
    ln -fs /etc/rancher/k3s/k3s.yaml ~ubuntu/.kube/config
  EOF
}

provider "aws" {
  region = var.region
}

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

  name                    = "${local.name}-manager"
  instance_type           = "t4g.small"
  ami                     = data.aws_ami.ubuntu.image_id
  ignore_ami_changes      = true
  disable_api_termination = true

  metadata_options = {
    http_endpoint               = "enabled",
    http_put_response_hop_limit = 1,
    http_tokens                 = "required"
  }

  subnet_id = module.vpc.private_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.egress.id,
    aws_security_group.intranet.id,
  ]

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
