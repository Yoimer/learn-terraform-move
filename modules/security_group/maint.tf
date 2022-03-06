variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

resource "aws_security_group" "sg_8080" {
  vpc_id      = var.vpc_id
  name = "terraform-learn-move-sg"
  ingress {
    from_port   = "8080"
    to_port     = "8080"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
