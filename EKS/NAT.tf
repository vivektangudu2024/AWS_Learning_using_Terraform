resource "aws_eip" "nat" {
    vpc = true

    tags = {
        name = "NAT"
    }
}

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.sub_1_public.id

    tags = {
        name = "NAT Gateway"
    }

    depends_on = [ aws_internet_gateway.My_IGW ]
}