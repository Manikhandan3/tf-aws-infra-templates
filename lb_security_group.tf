resource "aws_security_group" "lb_sg" {
  count  = var.vpc_count
  name   = "loadbalancer-security-group-${var.vpc_name}-${count.index}"
  vpc_id = aws_vpc.my_vpc[count.index].id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound access to application
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LB-SG-${var.vpc_name}-${count.index}"
  }
}