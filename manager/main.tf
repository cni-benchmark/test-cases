#  ┌┌┐┬─┐o┌┐┐
#  ││││─┤││││
#  ┘ ┘┘ ┘┘┘└┘

locals {
  name                             = var.tenant
  azs                              = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_cidr_block                   = var.vpc_cidr_block
  vpc_cidr_netmask                 = split("/", local.vpc_cidr_block)[1]
  manager_kubeconfig_ssm_parameter = "/cni-benchmark/${local.name}/manager-kubeconfig"
  manager_user_data                = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    
    echo "root:root" | chpasswd
    export DEBIAN_FRONTEND=noninteractive
    while sleep 5; do
      apt-get update -qqy || continue
      apt-get install -qqy zsh python3-pip git vim acl curl unzip || continue
      break
    done
    python3 -m pip install --upgrade ranger-fm --break-system-packages
    usermod -s "$(which zsh)" ubuntu
    usermod -s "$(which zsh)" root
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /opt/powerlevel10k
    echo 'source /opt/powerlevel10k/powerlevel10k.zsh-theme' | tee -a ~{root,ubuntu}/.zshrc
    cat <<EOT | tee -a ~{root,ubuntu}/{.zshrc,.bashrc}
    alias kubectl="k3s kubectl"
    alias k="kubectl"
    alias kg="kubectl get"
    alias ky="kubectl get -o yaml"
    alias kubens="kubectl config set-context --current --namespace"
    EOT

    arch="$(uname -m | sed -r 's/aarch/arm/g; s/x86_/amd/g')"
    curl -fsSLo /tmp/k9s.deb "https://github.com/derailed/k9s/releases/latest/download/k9s_linux_$arch.deb"
    dpkg -i /tmp/k9s.deb || true
    apt-get install -qqy -f

    token="$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")"
    public_ip="$(curl -fsS -H "X-aws-ec2-metadata-token: $token" http://169.254.169.254/latest/meta-data/public-ipv4)"
    public_hostname="$(curl -fsS -H "X-aws-ec2-metadata-token: $token" http://169.254.169.254/latest/meta-data/public-hostname)"
    curl -fsSL https://get.k3s.io | INSTALL_K3S_EXEC="server --tls-san $public_ip --tls-san $public_hostname" bash
    setfacl -Rm u:ubuntu:rwx /etc/rancher
    setfacl -dRm u:ubuntu:rwx /etc/rancher
    mkdir -p ~{root,ubuntu}/.kube
    ln -fs /etc/rancher/k3s/k3s.yaml ~root/.kube/config
    ln -fs /etc/rancher/k3s/k3s.yaml ~ubuntu/.kube/config

    (
      cd "$(mktemp -d)"
      curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      ./aws/install --bin-dir /usr/bin --update
    )
    cat /etc/rancher/k3s/k3s.yaml | \
    sed -ri "s/127.0.0.1|localhost/$public_ip/g" | \
    xargs -0 aws ssm put-parameter \
      --overwrite --name '${local.manager_kubeconfig_ssm_parameter}' --value

    date > /initialized
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

  name                        = "${local.name}-manager"
  instance_type               = "t4g.small"
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

resource "local_sensitive_file" "foo" {
  filename        = "${path.module}/kubeconfig.yaml"
  content         = data.aws_ssm_parameter.manager_kubeconfig.value
  file_permission = "0600"
}
