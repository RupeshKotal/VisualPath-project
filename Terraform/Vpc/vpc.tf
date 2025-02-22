provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}


resource "aws_subnet" "public-subnet" {
     vpc_id = aws_vpc.my-vpc.id
     cidr_block = "10.1.1.0/24"
     map_public_ip_on_launch = true
     availability_zone = "us-east-1a"

     tags = {
       Name = "my-public-subnet"
     }
  
}

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_nat_gateway" "my-nat" {
  subnet_id = aws_subnet.public-subnet.id
  allocation_id = aws_eip.my-eip.id

  tags = {
    name = "my-nat"
  }
}

resource "aws_eip" "my-eip" {
  vpc = true 
}


resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
}

resource "aws_route_table" "nat_route" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my-nat.id
  }
}


resource "aws_route_table_association" "rta-public" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.my-rt.id
}

resource "aws_route_table_association" "nat_assosiation" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.nat_route.id
}

resource "aws_security_group" "allow_http" {
  name = "my-public-sg"
    description = "Allow http inbound traffic and all outbound traffic"
    vpc_id = aws_vpc.my-vpc.id

    tags = {
      Name = "allow_http"
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }


    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}


resource "aws_security_group" "allow_private" {
  name = "my-private-sg"
    description = "Allow http inbound traffic and all outbound traffic"
    vpc_id = aws_vpc.my-vpc.id

    tags = {
      Name = "allow_private"
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}




resource "aws_instance" "my-public-ec2" {
  ami = "ami-05b10e08d247fb927"
  instance_type =  "t2.micro"
  key_name = "k8"
  vpc_security_group_ids = [ aws_security_group.allow_http.id ]
  subnet_id = aws_subnet.public-subnet.id

  tags = {
    Name = "public-ec2"
  }
}

resource "aws_instance" "my-private-ec2" {
  ami = "ami-05b10e08d247fb927"
  instance_type =  "t2.micro"
  key_name = "k8"
  vpc_security_group_ids = [ aws_security_group.allow_private.id ]
  subnet_id = aws_subnet.private-subnet.id

  tags = {
    Name = "private-ec2"
  }
}



