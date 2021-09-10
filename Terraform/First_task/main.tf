terraform {  
  backend "s3" {
    bucket         = "jiraiya106-terraform-state"    
    key            = "terraform.tfstate"    
    encrypt        = true  
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

#module "aws_es" {
#  source = "./modules/elasticsearch"

#domain_name         = "es-domain" 
#instance_count      = 2
#instance_type       = "r4.large.elasticsearch"
#tag_domain          = "ESDomain"
#volume_type         = "gp2"
#ebs_volume_size     = 10
#vpc_cidr            = var.vpc_cidr
#public_subnets_cidr = var.public_subnets_cidr
#region              = var.region
#}
