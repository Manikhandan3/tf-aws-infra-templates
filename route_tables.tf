# Public Route Table
resource "aws_route_table" "public_rt" {
  count  = var.vpc_count
  vpc_id = aws_vpc.my_vpc[count.index].id

  tags = {
    Name = "Public-RouteTable-${count.index}"
  }
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  count  = var.vpc_count
  vpc_id = aws_vpc.my_vpc[count.index].id

  tags = {
    Name = "Private-RouteTable-${count.index}"
  }
}
