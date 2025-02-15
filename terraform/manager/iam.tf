#  o┬─┐┌┌┐
#  ││─┤│││
#  ┘┘ ┘┘ ┘

resource "aws_iam_role" "manager" {
  name_prefix        = "${var.name}-manager-"
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
  name_prefix = "${var.name}-manager-"
  role        = aws_iam_role.manager.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.manager.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
