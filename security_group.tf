# Application Security Group
resource "aws_security_group" "application_sg" {
  count  = var.vpc_count
  name   = "application-security-group-${var.vpc_name}-${count.index}"
  vpc_id = aws_vpc.my_vpc[count.index].id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application port access from from load balancer
  ingress {
    from_port       = var.application_port
    to_port         = var.application_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg[count.index].id]
  }

  # General egress rule for other internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App-SG-${var.vpc_name}-${count.index}"
  }
}