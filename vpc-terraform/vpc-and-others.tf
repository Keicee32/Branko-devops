resource "aws_vpc" "my-vpc" {
    cidr_block = "192.168.0.0/16" 

    tags = {
        Name = "test-vpc"
    }
}

resource "aws_subnet" "my-public-subnet" {
    vpc_id = aws_vpc.my-vpc.id 
    cidr_block = "192.168.1.0/24"

    availability_zone = "us-east-1a"

    depends_on = [aws_vpc.my-vpc]
}

resource "aws_subnet" "my-private-subnet" {
    vpc_id = aws_vpc.my-vpc.id 
    cidr_block = "192.168.2.0/24"

    availability_zone = "us-east-1b"

    depends_on = [aws_vpc.my-vpc]
}

resource aws_internet_gateway "my-igw" {
    vpc_id = aws_vpc.my-vpc.id 

    tags = {
        Name = "my-igw-public"
    }
}