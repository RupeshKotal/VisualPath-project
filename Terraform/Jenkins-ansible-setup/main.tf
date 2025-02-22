provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
   cidr_block = "10.1.0.0/16"

   tags = {
     Name = "Project-vpc"
   }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "Project-public-subnet"
  }
}

resource "aws_internet_gateway" "project-igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags ={
    Name = "project-igw"
  }
}

resource "aws_route_table" "project-route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-igw.id
  }
}

resource "aws_route_table_association" "rt-a" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.project-route.id
}


resource "aws_security_group" "project-sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

 tags = {
   Name = "Project-sg"
 }

}


resource "aws_instance" "prject-ec2" {
  ami = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.medium"
  vpc_security_group_ids = [ aws_security_group.project-sg.id ]
  availability_zone = "us-east-1a"
  subnet_id = aws_subnet.public-subnet.id
  key_name = "k8"

   for_each = toset(["jenkins-master", "jenkins-slave", "ansible"])

   tags = {
     Name = "${each.key}"
   }

}