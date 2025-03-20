resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "csye6225-parameter-group"
  family = "mysql8.0" # Adjust based on your MySQL version

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  tags = {
    Name = "${var.vpc_name}-parameter-group"
  }
}

# Create DB subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  count      = var.vpc_count
  name       = "db-subnet-group-${var.vpc_name}-${count.index}"
  subnet_ids = [for i in range(length(var.availability_zones)) : aws_subnet.private_subnets[count.index * length(var.availability_zones) + i].id]

  tags = {
    Name = "DB-Subnet-Group-${var.vpc_name}-${count.index}"
  }
}