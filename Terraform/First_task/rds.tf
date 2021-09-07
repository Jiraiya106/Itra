#RDS
resource "aws_db_instance" "my-db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [ aws_security_group.db_sq.id ]
  skip_final_snapshot    = "true"

  tags = merge({ Name = "${var.common-tags["Name"]}-db"})
}

resource "aws_security_group" "db_sq" {
  name = "rds_sg"

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