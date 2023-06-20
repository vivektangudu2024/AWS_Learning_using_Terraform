resource "aws_internet_gateway" "My_IGW" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    name: "My IGW"
  }
}