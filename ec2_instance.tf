resource "aws_instance" "app_instance" {
  count = var.vpc_count

  ami                    = var.custom_ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnets[count.index * length(var.availability_zones)].id
  vpc_security_group_ids = [aws_security_group.application_sg[count.index].id]
  key_name               = aws_key_pair.app_key_pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_profile.name

  user_data = <<-EOF
  #!/bin/bash
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/csye6225/webapp/cloudwatch-agent.json \
  -s

  mkdir -p /opt/csye6225/webapp

  cat > /opt/csye6225/webapp/.env << EOL
  DB_HOST_DEV=${aws_db_instance.db_instance[count.index].address}
  PORT=${var.application_port}
  DB_NAME_DEV=${aws_db_instance.db_instance[count.index].db_name}
  DB_USERNAME_DEV=${aws_db_instance.db_instance[count.index].username}
  DB_PASSWORD_DEV=${var.db_password}
  DB_DIALECT_DEV=${var.db_dialect}
  S3_BUCKET=${aws_s3_bucket.app_bucket.id}
  AWS_REGION=${var.region}
  EOL

  sudo chown csye6225:csye6225 /opt/csye6225/webapp/.env
  sudo chmod 750 /opt/csye6225/webapp/.env

  EOF

  disable_api_termination = false

  root_block_device {
    volume_size           = 25
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "HealthCheckAPI-Instance-${var.vpc_name}-${count.index}"
  }
}