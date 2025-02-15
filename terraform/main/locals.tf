#  ┬  ┌─┐┌─┐┬─┐┬  ┐─┐
#  │  │ ││  │─┤│  └─┐
#  ┘─┘┘─┘└─┘┘ ┘┘─┘──┘

locals {
  name             = var.tenant
  azs              = slice(module.data.available_azs, 0, 3)
  vpc_cidr_block   = var.vpc_cidr_block
  vpc_cidr_netmask = split("/", local.vpc_cidr_block)[1]
  # manager_kubeconfig_ssm_parameter = "/cni-benchmark/${local.name}/manager-kubeconfig"
  # manager_user_data                = <<-EOF
  #   #!/bin/bash
  #   set -euxo pipefail

  #   echo "root:root" | chpasswd
  #   export DEBIAN_FRONTEND=noninteractive
  #   while sleep 5; do
  #     apt-get update -qqy || continue
  #     apt-get install -qqy zsh python3-pip git vim acl curl unzip || continue
  #     break
  #   done
  #   python3 -m pip install --upgrade ranger-fm --break-system-packages
  #   usermod -s "$(which zsh)" ubuntu
  #   usermod -s "$(which zsh)" root
  #   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /opt/powerlevel10k
  #   echo 'source /opt/powerlevel10k/powerlevel10k.zsh-theme' | tee -a ~{root,ubuntu}/.zshrc
  #   cat <<EOT | tee -a ~{root,ubuntu}/{.zshrc,.bashrc}
  #   alias kubectl="k3s kubectl"
  #   alias k="kubectl"
  #   alias kg="kubectl get"
  #   alias ky="kubectl get -o yaml"
  #   alias kubens="kubectl config set-context --current --namespace"
  #   EOT

  #   arch="$(uname -m | sed -r 's/aarch/arm/g; s/x86_/amd/g')"
  #   curl -fsSLo /tmp/k9s.deb "https://github.com/derailed/k9s/releases/latest/download/k9s_linux_$arch.deb"
  #   dpkg -i /tmp/k9s.deb || true
  #   apt-get install -qqy -f

  #   token="$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")"
  #   public_ip="$(curl -fsS -H "X-aws-ec2-metadata-token: $token" http://169.254.169.254/latest/meta-data/public-ipv4)"
  #   public_hostname="$(curl -fsS -H "X-aws-ec2-metadata-token: $token" http://169.254.169.254/latest/meta-data/public-hostname)"
  #   curl -fsSL https://get.k3s.io | INSTALL_K3S_EXEC="server --tls-san $public_ip --tls-san $public_hostname" bash
  #   setfacl -Rm u:ubuntu:rwx /etc/rancher
  #   setfacl -dRm u:ubuntu:rwx /etc/rancher
  #   mkdir -p ~{root,ubuntu}/.kube
  #   ln -fs /etc/rancher/k3s/k3s.yaml ~root/.kube/config
  #   ln -fs /etc/rancher/k3s/k3s.yaml ~ubuntu/.kube/config

  #   (
  #     cd "$(mktemp -d)"
  #     curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip"
  #     unzip awscliv2.zip
  #     ./aws/install --bin-dir /usr/bin --update
  #   )
  #   cat /etc/rancher/k3s/k3s.yaml | \
  #   sed -r "s/127.0.0.1|localhost/$public_ip/g" | \
  #   xargs -0 aws ssm put-parameter \
  #     --overwrite --name '${local.manager_kubeconfig_ssm_parameter}' --value

  #   (
  #     mkdir -p /var/lib/rancher/k3s/server/manifests
  #     cd /var/lib/rancher/k3s/server/manifests
  #     echo '${base64encode(yamlencode(local.ks_global_configmap))}' | base64 -d | tee ks-global-variables.yaml
  #   )
  #   curl -fsSL https://github.com/cni-benchmark/test-cases/raw/refs/heads/main/manager/kubernetes/init.sh | bash

  #   date > /initialized
  # EOF
  # ks_global_configmap = {
  #   apiVersion = "v1"
  #   kind       = "ConfigMap"
  #   metadata = {
  #     name      = "ks-global-variables"
  #     namespace = "default"
  #   }
  #   data = {
  #     AWS_REGION              = data.aws_region.this.name
  #     AWS_VPC_ID              = module.vpc.vpc_id
  #     AWS_PUBLIC_SUBNET_A_ID  = module.vpc.public_subnets[0]
  #     AWS_PUBLIC_SUBNET_B_ID  = module.vpc.public_subnets[1]
  #     AWS_PUBLIC_SUBNET_C_ID  = module.vpc.public_subnets[2]
  #     AWS_PRIVATE_SUBNET_A_ID = module.vpc.private_subnets[0]
  #     AWS_PRIVATE_SUBNET_B_ID = module.vpc.private_subnets[1]
  #     AWS_PRIVATE_SUBNET_C_ID = module.vpc.private_subnets[2]
  #     AWS_INTRANET_SG_ID      = aws_security_group.intranet.id
  #     AWS_EGRESS_SG_ID        = aws_security_group.egress.id
  #   }
  # }
}
