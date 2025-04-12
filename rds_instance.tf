resource "aws_db_instance" "db_instance" {
  count = var.vpc_count

  identifier                 = "csye6225"
  engine                     = "mysql"
  engine_version             = "8.0"
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  storage_type               = "gp3"
  db_name                    = var.db_name
  username                   = var.db_username
  password                   = random_password.db_password.result
  parameter_group_name       = aws_db_parameter_group.db_parameter_group.name
  db_subnet_group_name       = aws_db_subnet_group.db_subnet_group[count.index].name
  vpc_security_group_ids     = [aws_security_group.database_sg[count.index].id]
  publicly_accessible        = false
  skip_final_snapshot        = true
  multi_az                   = false
  backup_retention_period    = 7
  deletion_protection        = false
  auto_minor_version_upgrade = true
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.rds_encryption_key.arn

  tags = {
    Name = "RDS-${var.vpc_name}-${count.index}"
  }
}