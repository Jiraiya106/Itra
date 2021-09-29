locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

resource "aws_vpc" "aws_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.aws_vpc.id
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr,   count.index)}"
  availability_zone       = "${element(local.production_availability_zones,   count.index)}"
  map_public_ip_on_launch = true
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.domain_name
  elasticsearch_version = "7.10"

  cluster_config {
    instance_count = var.instance_count
    instance_type = var.instance_type
    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = 2
    }
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }
  vpc_options {
    subnet_ids = [aws_subnet.public_subnet.0.id, aws_subnet.public_subnet.1.id]
  }
  ebs_options {
    ebs_enabled = var.ebs_volume_size > 0 ? true : false
    volume_size = var.ebs_volume_size
    volume_type = var.volume_type
  }
  tags = {
    Domain = var.tag_domain
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
  description      = "Allows Amazon ES to manage AWS resources for a domain on your behalf."
}


resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.es.domain_name
  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "${aws_elasticsearch_domain.es.arn}/*"
        }
    ]
}
POLICIES
}