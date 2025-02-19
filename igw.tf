resource "aws_internet_gateway" "igw" {
  count  = var.vpc_count
  vpc_id = aws_vpc.my_vpc[count.index].id

  tags = {
    Name = "InternetGateway-${var.vpc_name}-${count.index}"
  }
}
