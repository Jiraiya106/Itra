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
  public_key = var.ssh_public_key
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