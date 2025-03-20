resource "aws_security_group" "database_sg" {
  count  = var.vpc_count
  name   = "database-security-group-${var.vpc_name}-${count.index}"
  vpc_id = aws_vpc.my_vpc[count.index].id

  # MySQL access from application security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg[count.index].id]
  }

  tags = {
    Name = "DB-SG-${var.vpc_name}-${count.index}"
  }
}