resource "aws_instance" "app_instance" {
  count = var.vpc_count

  ami                    = var.custom_ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnets[count.index * length(var.availability_zones)].id
  vpc_security_group_ids = [aws_security_group.application_sg[count.index].id]


  disable_api_termination = false

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "HealthCheckAPI-Instance-${var.vpc_name}-${count.index}"
  }
}