resource "tls_private_key" "app_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "app_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.app_private_key.public_key_openssh

  tags = {
    Name = "${var.vpc_name}-keypair"
  }
}

resource "local_file" "private_key_file" {
  content         = tls_private_key.app_private_key.private_key_pem
  filename        = "${var.key_output_path}/${var.key_name}.pem"
  file_permission = "0400" # Restricted permissions for security
}