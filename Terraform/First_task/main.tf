provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

#VPC
resource "aws_vpc" "aws_vpc" {
	cidr_block       = "10.0.0.0/16"
	instance_tenancy = "default"
    
    tags = {
      Name = "my_vpc"
    }
}

#Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.aws_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "my_private_subnet"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.aws_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "my_private_subnet_2"
  }
}

#EC2-App
resource "aws_instance" "instance-app" {
  ami = "ami-05f7491af5eef733a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_subnet.id 
  vpc_security_group_ids = [ aws_security_group.allow_tls_app.id ]
  tags = merge({ Name = "${var.common-tags["Name"]}-app"})
}

#Security group EC2-App
resource "aws_security_group" "allow_tls_app" {
  name        = "allow_tls_app"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.aws_vpc.id

  dynamic "ingress" {
  for_each = var.allow_port_app
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"] # Уточнить блоки при создании ELB
    }  
  }
  
  ingress {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [aws_instance.bastion.ipv4] # Уточнить блок при создании bastion
  }   

  egress  {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  

  tags = {
    Name = "allow_port_app"
  }
}

#RDS
#resource "aws_db_subnet_group" "my-db" {
#  name       = "subnet-group"
#  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_2.id]
  

#  tags = {
#    Name = "My DB subnet group"
#  }
#}

#resource "aws_db_instance" "my-db" {
#  allocated_storage    = 10
#  engine               = "mysql"
#  engine_version       = "5.7"
#  instance_class       = "db.t3.micro"
#  name                 = "mydb"
# username             = var.db_username
#  password             = var.db_password
#  parameter_group_name = "default.mysql5.7"
#  db_subnet_group_name = aws_db_subnet_group.my-db.id
#  vpc_security_group_ids = [ aws_security_group.allow_port_db.id ]

#  tags = merge({ Name = "${var.common-tags["Name"]}-db"})
#}


#resource "aws_security_group" "allow_port_db" {
#  name        = "allow_tls_db"
#  description = "Allow TLS inbound traffic"
#  vpc_id      = aws_vpc.aws_vpc.id

#  dynamic "ingress" {
#  for_each = var.allow_port_db
#    content {
#      from_port        = ingress.value
#      to_port          = ingress.value
#      protocol         = "tcp"
#      cidr_blocks      = ["0.0.0.0/0"] # Уточнить блоки при создании ELB
#    }  
#  }

#  egress  {
#      from_port        = 0
#      to_port          = 0
#      protocol         = "-1"
#      cidr_blocks      = ["0.0.0.0/0"]
#      ipv6_cidr_blocks = ["::/0"]
#    }
  

#  tags = {
#    Name = "allow_port_db"
#  }
#}

#EC2-instance bastion

resource "aws_instance" "bastion" {
  ami                         = "ami-969ab1f6"
  key_name                    = "${aws_key_pair.bastion_key.key_name}"
  instance_type               = "t2.micro"
  security_groups             = ["${aws_security_group.bastion-sg.name}"]
  associate_public_ip_address = true
  user_data                   = file("jenkins.sh")
}

resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "your_key_name"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDG6chvAZgOHfAHp08nWkGJE/57vYImLd+m2k0meZFz0MNcS3Nss94+F+lShQZam6ORgr0IyOWCHlE1A2TK1ZIJvGTiKX+v2YLkaMN82UQP7ApnB3FwlFCp9stHA9XaHQVATVi2uJU19zuDz/eznuV8JLsgyB99RPrjE9kmBWVLU+haOuq/hAuyznRTexdBcOEBQsPb9oZYQusQcdpli2FvHOCRKWoDGdxflRNu4ocXUZ3HWAGTR4Uv4k4+8cqPgrjaEGOLXKiCxBf2toSWC2iVP50DjPKnfeogy5MEJmcwDghtN9dfi6EZMfnRAUiNTJEvxwTPmGhjWm6LwQ+5hoH4QGPRotn7B5pnC6sJwEMjiFZWqEcEzg+uiGRIoN6mtZENJmajOAkLuOuHqf7YEMUUxBI+nAb+zqzuugFyXPLfT21bEoMm8Z6gZZr7aqAZaht4I8T8hfe6MmSH3dDIAbiA2u6QjV9cRCf3KWsh+MWO9+0TSXNqDLJNSfvEO+b4MEM= e.ilin@cmdb-97852"
}

output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}