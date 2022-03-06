variable "security_group" {
 description = "The security groups assigned to this instance"
}

variable "public_subnets" {
  description = "The public subnet IDs assigned to this instance for IP address assignment"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = var.public_subnets[0]
  instance_type          = "t2.micro"
  vpc_security_group_ids = [var.security_group]
  user_data              = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    Name = "terraform-learn-move-ec2"
  }
}