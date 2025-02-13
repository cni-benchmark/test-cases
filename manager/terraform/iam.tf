#  o┬─┐┌┌┐
#  ││─┤│││
#  ┘┘ ┘┘ ┘

module "cluster_api_iam" {
  source = "./cluster-api-iam"
  name   = local.name
}

resource "aws_iam_role" "manager" {
  name_prefix        = "${local.name}-manager-"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ec2.json
}

data "aws_iam_policy_document" "assume_by_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "manager" {
  name_prefix = "${local.name}-manager-"
  role        = aws_iam_role.manager.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.manager.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "manager_ssm_put_parameter_kubeconfig" {
  name_prefix = "${local.name}-manager-ssm-put-kubeconfig-"
  role        = aws_iam_role.manager.id
  policy      = data.aws_iam_policy_document.manager_ssm_put_parameter_kubeconfig.json
}

data "aws_iam_policy_document" "manager_ssm_put_parameter_kubeconfig" {
  statement {
    sid       = "ManagerKubeconfigPutParameter"
    actions   = ["ssm:PutParameter"]
    resources = [aws_ssm_parameter.manager_kubeconfig.arn]
  }
}

resource "aws_iam_role_policy_attachment" "cluster_api_controllers" {
  role       = aws_iam_role.manager.name
  policy_arn = module.cluster_api_iam.cloudformation.ControllersPolicyArn
}

resource "aws_iam_role_policy_attachment" "cluster_api_controllers_eks" {
  role       = aws_iam_role.manager.name
  policy_arn = module.cluster_api_iam.cloudformation.ControllersEKSPolicyArn
}
