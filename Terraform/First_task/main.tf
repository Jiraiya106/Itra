provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

resource "aws_vpc" "aws_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.aws_vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}
/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
  }
}
/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.aws_vpc.id
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr,   count.index)}"
  availability_zone       = "${element(local.production_availability_zones,   count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-${element(local.production_availability_zones, count.index)}-      public-subnet"
    Environment = "${var.environment}"
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.aws_vpc.id
  count                   = "${length(var.private_subnets_cidr)}"
  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone       = "${element(local.production_availability_zones,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${element(local.production_availability_zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
  }
}
/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.aws_vpc.id
  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aws_vpc.id
  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = aws_route_table.private.id
}
#ALB
resource "aws_lb" "my-alb" {
  name               = "my-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls_alb.id]
  subnets            = aws_subnet.public_subnet.*.id

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "target-group" {
  name     = "target-group-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.aws_vpc.id
}


resource "aws_lb_listener" "my-alb-listner" {
  load_balancer_arn = aws_lb.my-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.instance-app.id
  port             = 80
}

resource "aws_security_group" "allow_tls_alb" {
  name        = "allow_tls_alb"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.aws_vpc.id

  dynamic "ingress" {
  for_each = var.allow_port_alb
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"] # Уточнить блоки при создании ELB
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
    Name = "allow_port_alb"
  }
}

/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.aws_vpc.id
  depends_on  = [aws_vpc.aws_vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}

#EC2-instance bastion

resource "aws_instance" "bastion" {
  ami                         = "ami-0194c3e07668a7e36"
  key_name                    = aws_key_pair.bastion_key.key_name
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.1.id
  user_data                   = file("jenkins.sh")

  tags = merge({ Name = "${var.common-tags["Name"]}-bastion"})
}

resource "aws_security_group" "bastion_sg" {
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

#EC2-App
resource "aws_instance" "instance-app" {
  ami                    = "ami-0194c3e07668a7e36"
  key_name               = aws_key_pair.bastion_key.key_name
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet.0.id 
  vpc_security_group_ids = [ aws_security_group.allow_tls_app.id ]
  user_data              = file("apache.sh")
  tags                   = merge({ Name = "${var.common-tags["Name"]}-app"})
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
      cidr_blocks      = ["0.0.0.0/0"] # Уточнить блок при создании bastion
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
resource "aws_db_instance" "my-db" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [ aws_security_group.db_sq.id ]
  skip_final_snapshot = "true"

  tags = merge({ Name = "${var.common-tags["Name"]}-db"})
}

resource "aws_security_group" "db_sq" {
  name = "rds_sg"

  dynamic "ingress" {
  for_each = var.allow_port_db
    content {
      from_port        = ingress.value
      to_port          = ingress.value
     protocol         = "tcp"
    cidr_blocks     = ["10.0.1.0/24"]
    }
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}