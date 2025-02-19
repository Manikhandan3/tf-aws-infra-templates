resource "aws_subnet" "public_subnets" {
  count = var.vpc_count * length(var.availability_zones)

  vpc_id                  = aws_vpc.my_vpc[floor(count.index / length(var.availability_zones))].id
  cidr_block              = cidrsubnet(aws_vpc.my_vpc[floor(count.index / length(var.availability_zones))].cidr_block, 8, count.index)
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-${var.vpc_name}-${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = var.vpc_count * length(var.availability_zones)

  vpc_id            = aws_vpc.my_vpc[floor(count.index / length(var.availability_zones))].id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc[floor(count.index / length(var.availability_zones))].cidr_block, 8, count.index + length(aws_subnet.public_subnets))
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = {
    Name = "Private-Subnet-${var.vpc_name}-${count.index}"
  }
}
