resource "aws_route" "public_internet_access" {
  count = var.vpc_count

  route_table_id         = aws_route_table.public_rt[count.index].id
  destination_cidr_block = var.pr_dest_cidr
  gateway_id             = aws_internet_gateway.igw[count.index].id
}
