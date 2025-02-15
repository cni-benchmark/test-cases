#  ┐─┐┬─┐┌─┐┬ ┐┬─┐o┌┐┐┐ ┬
#  └─┐├─ │  │ ││┬┘│ │ └┌┘
#  ──┘┴─┘└─┘┘─┘┘└┘┘ ┘  ┘ 

resource "aws_security_group" "egress" {
  name_prefix = "${local.name}-egress-"
  description = "Allows outgoing traffic"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "egress_ipv4" {
  security_group_id = aws_security_group.egress.id
  description       = "Anywhere"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "egress_ipv6" {
  security_group_id = aws_security_group.egress.id
  description       = "Anywhere"
  ip_protocol       = "-1"
  cidr_ipv6         = "::/0"
}


resource "aws_security_group" "intranet" {
  name_prefix = "${local.name}-intranet-"
  description = "Allows traffic from the same SG"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "intranet" {
  security_group_id            = aws_security_group.intranet.id
  referenced_security_group_id = aws_security_group.intranet.id
  description                  = "Same SG"
  ip_protocol                  = "-1"
}

resource "aws_security_group" "admin" {
  count       = length(var.admin_cidr_blocks) > 0 ? 1 : 0
  name_prefix = "${local.name}-admin-"
  description = "Full access from admin CIDRs"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "admin" {
  for_each          = toset(var.admin_cidr_blocks)
  security_group_id = aws_security_group.admin[0].id
  description       = "Admin CIDRs"
  cidr_ipv4         = each.value
  ip_protocol       = "-1"
}
