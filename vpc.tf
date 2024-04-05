# Fetch available Availability Zones in the region
data "aws_availability_zones" "available" {}


resource "aws_vpc" "my_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "My-Site-VPC"
  }
}

resource "aws_subnet" "my_sub0" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "My-Site-VPC-Subnet-1"
  }
}

resource "aws_subnet" "my_sub1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "My-Site-VPC-Subnet-2"
  }
}

resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My-Site-VPC-IG"
  }
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_vpc.my_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_internet_gateway.id
}

# Create VPC endpoint for S3 using PrivateLink
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id             = aws_vpc.my_vpc.id
  service_name       = "com.amazonaws.us-east-2.s3"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  subnet_ids         = [aws_subnet.my_sub0.id, aws_subnet.my_sub1.id]
  tags = {
    Environment = "My-S3-VPC-Endpoint"
  }
}
