resource "aws_route_table" "private" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      name = "Private"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      name = "Public"
    }
}

resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.My_IGW.id
}

resource "aws_route_table_association" "sub_1_private" {
    subnet_id = aws_subnet.sub_1_private.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "sub_2_private" {
    subnet_id = aws_subnet.sub_2_private.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "sub_1_public" {
    subnet_id = aws_subnet.sub_1_public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "sub_2_public" {
    subnet_id = aws_subnet.sub_2_public.id
    route_table_id = aws_route_table.public.id
}
