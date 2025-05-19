provider "aws" {
    region = "us-east-1"  
}

resource "aws_instance" "demo_server" {
    ami = "ami-0953476d60561c955"
    instance_type = "t2.micro"
    key_name   = "Demo_key_pair"
    vpc_security_group_ids =   [aws_security_group.demo-sg.id]
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "ssh access"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
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