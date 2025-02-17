resource "aws_vpc" "my_vpc" {
  count                = var.vpc_count
  cidr_block           = var.vpc_cidrs[count.index]
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-${count.index}"
  }
}