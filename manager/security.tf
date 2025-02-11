#  ┐─┐┬─┐┌─┐┬ ┐┬─┐o┌┐┐┐ ┬
#  └─┐├─ │  │ ││┬┘│ │ └┌┘
#  ──┘┴─┘└─┘┘─┘┘└┘┘ ┘  ┘ 

resource "aws_security_group" "egress" {
  name_prefix = "${local.name}-egress-"
  description = "Allows outgoing traffic"
  vpc_id      = module.vpc.vpc_id

  egress {
    description      = "Anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "intranet" {
  name_prefix = "${local.name}-intranet-"
  description = "Allows traffic from the same SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Same SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
