terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_security_group" "example" {
  name_prefix = "example_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test-cluster" {
  ami           = "ami-082b1f4237bd816a1" # public ami for ubuntu:22.04
  instance_type = "t2.micro"
  key_name      = "npkey"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.example.id
  ]

  tags = {
    Name    = "my-instance"
    purpose = "development"
    env     = "dev"
    }

  root_block_device  {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  ebs_block_device  {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }

  volume_tags = {
    Name    = "example"
    Purpose = "data-storage"
    Env     = "dev"
    Team    = "engineering"
    }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt install -y git",
      "git clone https://github.com/Clarinovist/cilist.git",
      "cd cilist",
      "sudo chmod +x install-docker.sh", 
      "sudo ./install-docker.sh",
    ]

    connection {
      host = self.public_ip
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/npkey.pem")
    }
  }
}
