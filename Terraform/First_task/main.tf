provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region

}

#EC2
resource "aws_instance" "my_ubuntu" {
  ami = ""
  instance_type = "t2.micro"
  user_data = <<EOF
#!/bin/bash
"wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
"sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
"sudo apt update -qq",
"sudo apt install -y default-jre",
"sudo apt install -y jenkins",
"sudo systemctl start jenkins",
"sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
"sudo sh -c \"iptables-save > /etc/iptables.rules\"",
"echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
"echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
"sudo apt-get -y install iptables-persistent",
"sudo ufw allow 8080",
EOF
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
	instance_class         = "db.t2.micro"
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

  dynamic "ingress" {
  for_each = ["80", "443", "8080", "1541", "9092"]
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }  
  }
  
  egress  {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  

  tags = {
    Name = "allow_tls"
  }
}