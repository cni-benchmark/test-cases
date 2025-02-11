#  ┬─┐┬─┐┌┐┐┬─┐
#  │ ││─┤ │ │─┤
#  ┘─┘┘ ┘ ┘ ┘ ┘

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-.+"
  owners      = ["099720109477"]
}
