#RDS
resource "aws_db_instance" "my-db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  identifier             = "${var.db_name}-${var.env}-db"
  name                   = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [ aws_security_group.db_sq.id ]
  db_subnet_group_name   = aws_db_subnet_group.db-group.id
  skip_final_snapshot    = "true"

  tags = merge({ Name = "${var.common-tags["Name"]}-db"})
}

resource "aws_security_group" "db_sq" {
  name = "rds_sg-${var.env}"
  vpc_id = aws_vpc.aws_vpc.id

  dynamic "ingress" {
  for_each = var.allow_port_db
    content {
      from_port        = ingress.value
      to_port          = ingress.value
     protocol          = "tcp"
    cidr_blocks        = ["0.0.0.0/0"]
    }
  }

    egress {
    from_port          = 0
    to_port            = 0
    protocol           = "-1"
    cidr_blocks        = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db-group" {
  name       = "main-${var.env}"
  subnet_ids = [aws_subnet.public_subnet.0.id, aws_subnet.public_subnet.1.id, aws_subnet.private_subnet.0.id]

  tags = {
    Name = "My DB subnet group"
  }
}