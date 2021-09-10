data "aws_ami" "ubuntu_20" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

#EC2-instance bastion

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu_20.id
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
  key_name   = "your_key_name-${var.env}"
  public_key = var.ssh_public_key
}

#EC2-App
data "template_file" "phpconfig" {
  template = file("files/conf.wp-config.php")

  vars = {
    db_port = aws_db_instance.my-db.port
    db_host = aws_db_instance.my-db.address
    db_user = var.db_username
    db_pass = var.db_password
    db_name = var.db_name
  }
}

resource "aws_instance" "instance-app" {
  ami                    = data.aws_ami.ubuntu_20.id
  key_name               = aws_key_pair.bastion_key.key_name
  instance_type          = "t2.micro"

  depends_on = [
    aws_db_instance.my-db,
  ]  

  subnet_id              = aws_subnet.private_subnet.0.id 
  vpc_security_group_ids = [ aws_security_group.allow_tls_app.id ]
  user_data              = file("files/userdata.sh")
  tags                   = merge({ Name = "${var.common-tags["Name"]}-app"})

provisioner "file" {
    source      = "./files/userdata.sh"
    destination = "/tmp/userdata.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.private_ip
      bastion_host = aws_instance.bastion.public_ip
      bastion_host_key = aws_key_pair.bastion_key.key_name
      bastion_user = "ubuntu"
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/userdata.sh",
      "/tmp/userdata.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.private_ip
      bastion_host = aws_instance.bastion.public_ip
      bastion_host_key = aws_key_pair.bastion_key.key_name
      bastion_user = "ubuntu"
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "file" {
    content     = data.template_file.phpconfig.rendered
    destination = "/tmp/wp-config.php"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.private_ip
      bastion_host = aws_instance.bastion.public_ip
      bastion_host_key = aws_key_pair.bastion_key.key_name
      bastion_user = "ubuntu"
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/wp-config.php /var/www/html/wp-config.php",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.private_ip
      bastion_host = aws_instance.bastion.public_ip
      bastion_host_key = aws_key_pair.bastion_key.key_name
      bastion_user = "ubuntu"
      private_key = file(var.ssh_priv_key)
    }
  }

provisioner "file" {
    source     = "./files/create-admin-user.php"
    destination = "/tmp/create-admin-user.php"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.private_ip
      bastion_host = aws_instance.bastion.public_ip
      bastion_host_key = aws_key_pair.bastion_key.key_name
      bastion_user = "ubuntu"
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/create-admin-user.php /var/www/html/wp-content/mu-plugins/create-admin-user.php",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.private_ip
      bastion_host = aws_instance.bastion.public_ip
      bastion_host_key = aws_key_pair.bastion_key.key_name
      bastion_user = "ubuntu"
      private_key = file(var.ssh_priv_key)
    }
  }



  timeouts {
    create = "20m"
  }
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