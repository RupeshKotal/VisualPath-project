provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my-ec2" {
    ami = "ami-05b10e08d247fb927"
    instance_type =  "t2.micro"
    key_name = "k8"
    security_groups = [ aws_security_group.allow_ssh.name ]
 }

 resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic and all outbound traffic"


  tags = {
    Name = "allow_ssh"
  }

     ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

