resource "aws_launch_template" "app_launch_template" {
  name          = "csye6225_asg"
  image_id      = var.custom_ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.app_key_pair.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_s3_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application_sg[0].id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 \
    -c file:/opt/csye6225/webapp/cloudwatch-agent.json \
    -s

    mkdir -p /opt/csye6225/webapp

    cat > /opt/csye6225/webapp/.env << EOL
    DB_HOST_DEV=${aws_db_instance.db_instance[0].address}
    PORT=${var.application_port}
    DB_NAME_DEV=${aws_db_instance.db_instance[0].db_name}
    DB_USERNAME_DEV=${aws_db_instance.db_instance[0].username}
    DB_PASSWORD_DEV=${var.db_password}
    DB_DIALECT_DEV=${var.db_dialect}
    S3_BUCKET=${aws_s3_bucket.app_bucket.id}
    AWS_REGION=${var.region}
    EOL

    sudo chown csye6225:csye6225 /opt/csye6225/webapp/.env
    sudo chmod 750 /opt/csye6225/webapp/.env
  EOF
  )

  disable_api_termination = false

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Webapp-Instance-${var.vpc_name}"
    }
  }
}