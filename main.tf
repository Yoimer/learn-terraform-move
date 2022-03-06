terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-laboratory"
    key     = "tfstates/tf-poc.tfstate"
    region  = "us-west-2"
    encrypt = "true"
    profile = "dino-lab"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region = var.region
}

# module "vpc" {
module "learn_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

module "ec2_instance" {
  source         = "./modules/compute"
  security_group = module.security_group.sg_id
  # public_subnets = module.vpc.public_subnets
  public_subnets = module.learn_vpc.public_subnets

}

module "security_group" {
  source = "./modules/security_group"
  # vpc_id = module.vpc.vpc_id
  vpc_id = module.learn_vpc.vpc_id
}

moved {
  from = aws_instance.example
  to = module.ec2_instance.aws_instance.example
}

moved {
  from = aws_security_group.sg_8080
  to = module.security_group.aws_security_group.sg_8080
}

moved {
  from = module.vpc
  to   = module.learn_vpc
}
