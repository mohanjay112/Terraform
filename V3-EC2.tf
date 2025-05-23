provider "aws" {
    region = "us-east-1"  
}

resource "aws_instance" "demo_server" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"
    key_name   = "Demo_key_pair"
    vpc_security_group_ids =   [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.dpp-public-subnet-01.id
    for_each =  toset(["Jenkins-master","build-slave","ansible"])
    tags = {
      Name = "${each.key}"
    }
    associate_public_ip_address = true
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "ssh access"
  vpc_id = aws_vpc.dpp-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jenkins port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc" "dpp-vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "dpp-vpc"
    }    
}
resource "aws_subnet" "dpp-public-subnet-01" {
    vpc_id = aws_vpc.dpp-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
        Name = "dpp-public-subnet-01"
    }
  
}

resource "aws_subnet" "dpp-public-subnet-02" {
    vpc_id = aws_vpc.dpp-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"
    tags = {
        Name = "dpp-public-subnet-02"
    }
  
}

resource "aws_internet_gateway" "dpp-igw" {
    vpc_id = aws_vpc.dpp-vpc.id
    tags = {
      Name  = "dpp-igw"
    }
  
}

resource "aws_route_table" "dpp-public-rt" {
    vpc_id = aws_vpc.dpp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpp-igw.id
    }
  
}
resource "aws_route_table_association" "dpp-rta-public-subnet-01" {
    subnet_id = aws_subnet.dpp-public-subnet-01.id
    route_table_id = aws_route_table.dpp-public-rt.id
  
}
resource "aws_route_table_association" "dpa-rta-public-subnet-02" {
    subnet_id = aws_subnet.dpp-public-subnet-02.id
    route_table_id = aws_route_table.dpp-public-rt.id 
}