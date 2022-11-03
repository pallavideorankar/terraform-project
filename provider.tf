provider "aws" {
  region = "eu-west-3"
}
#######vpc############
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

#########igw##########
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}


######subnet#######
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet1"
  }
}

###########RT###########
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route = []

  tags = {
    Name = "RT"
  }
}

############Routes##########
resource "aws_route" "rt" {
  route_table_id         = aws_route_table.RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.RT]
}

###########sg####
resource "aws_security_group" "sg" {
  name        = "allow_all_traffic"
  description = "Allow all inbound traffic "
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "all traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "all traffic"

  }
}

###########RT association#############
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.RT.id
}

#########ec2 instance########
resource "aws_instance" "aws" {
  ami           = "ami-02b01316e6e3496d9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1.id
  tags = {
    Name = "HelloWorld"
  }
}


