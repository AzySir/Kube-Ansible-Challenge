
resource "aws_security_group" "everis_sg" {
  name   = "everis-app-sg"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "everis-app-sg"
  }
}

resource "aws_security_group_rule" "icmp_ingress" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.everis_sg.id
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.everis_sg.id
}

resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.everis_sg.id
}

resource "aws_security_group_rule" "ingress_all_to_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  source_security_group_id = aws_security_group.everis_sg.id
  security_group_id        = aws_security_group.everis_sg.id
  depends_on               = [aws_instance.worker]
}

