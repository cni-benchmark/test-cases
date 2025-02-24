#  ┌┌┐┬─┐o┌┐┐
#  ││││─┤││││
#  ┘ ┘┘ ┘┘┘└┘

module "ec2" {
  source = "../modules/ec2-instance"

  name                   = "${var.name}-manager"
  instance_type          = "t4g.medium"
  ami                    = module.data.ami.talos_arm64.image_id
  iam_instance_profile   = aws_iam_instance_profile.manager.name
  vpc_subnet_id          = var.vpc_subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  root_size              = 20
}

module "talos" {
  source = "../providers/talos"

  name = var.name
  ec2  = module.ec2.outputs
  config_patches = [yamlencode({
    cluster = {
      extraManifests = [
        "https://github.com/cni-benchmark/test-cases/raw/refs/heads/main/kubernetes/manager/install.yaml"
      ]
    }
  })]

  depends_on = [module.ec2]
}
