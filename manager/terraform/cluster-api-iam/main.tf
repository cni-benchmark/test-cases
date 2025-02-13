#  ┬─┐┐ ┬┐─┐
#  │─┤│││└─┐
#  ┘ ┘└┴┘──┘

resource "aws_cloudformation_stack" "this" {
  name         = "${var.name}-cluster-api-iam"
  capabilities = ["CAPABILITY_NAMED_IAM"]
  template_body = join("\n", [
    file("${path.module}/stack.yaml"),
    file("${path.module}/outputs.yaml")
  ])
}
