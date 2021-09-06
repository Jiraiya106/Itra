terraform {  
  backend "s3" {
    profile = "terraform"
    shared_credentials_file = "~/.aws/credentials"
    bucket         = "jiraiya106-terraform-state"    
    key            = "terraform.tfstate"    
    dynamodb_table = "jiraiya106-terraform-state-locks"
    region         =  "eu-west-2"   
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

output "ubuntu_20" {
  value = data.aws_ami.ubuntu_20.id
}

module "aws_es" {
  source = "./modules/elasticsearch"

domain_name         = "es-domain" 
instance_count      = 2
instance_type       = "r4.large.elasticsearch"
tag_domain          = "ESDomain"
volume_type         = "gp2"
ebs_volume_size     = 10
access_key          = "AKIA6N57SLLXVU6MQUV3"
secret_key          = "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"
vpc_cidr            = var.vpc_cidr
public_subnets_cidr = var.public_subnets_cidr
region              = var.region
}
