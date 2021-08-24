# terraform {
#    required_providers {
#     aws = {
#       source   =  "hashicorp/aws" 
#       version =  " 2.70.0 "
#     }
#   }
# }

provider "aws" {
  access_key = ""
  secret_key = ""
  region = "eu-central-1"

}

#EC2
resource "aws_instance" "my_ubuntu" {
  ami = ""
  instance_type = "t2.micro"
}

#VPC
resource "aws_vpc" "aws_vpc" {
	cidr_block = "10.0.0.0/16"
	instance_tenancy = "default"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.aws_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

#RDS
resource "aws_db_instance" "education" {  
	identifier             = "education"
	instance_class         = "db.t3.micro"
	allocated_storage      = 5
	engine                 = "postgres"
	engine_version         = "13.1"
	username               = "edu"
	password               = var.db_password
	db_subnet_group_name   = aws_db_subnet_group.education.name
	vpc_security_group_ids = [aws_security_group.rds.id]
	parameter_group_name   = aws_db_parameter_group.education.name
	publicly_accessible    = true
	skip_final_snapshot    = true
}

#Load Balancer
resource "aws_lb" "app" {  
	name               = "main-app-lb"  
	internal           = false  
	load_balancer_type = "application"  
	subnets            = module.vpc.public_subnets  
	security_groups    = [module.lb_security_group.this_security_group_id]
	}

resource "aws_lb_listener" "app" {  
	load_balancer_arn = aws_lb.app.arn  
	port              = "80"  
	protocol          = "HTTP"

  default_action {    
	type             = "forward"    
	target_group_arn = aws_lb_target_group.blue.arn  
	}
}

#Security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.aws_vpc.id

  ingress = [
    {
      description      = "TLS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "allow_tls"
  }
}