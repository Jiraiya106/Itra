output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "alb-ip" {
  value = aws_lb.my-alb.dns_name
}
