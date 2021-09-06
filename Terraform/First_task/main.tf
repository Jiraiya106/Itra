
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

terraform {  
  backend "s3" {
    # Поменяйте это на имя своего бакета!
    bucket         = "jiraiya106-terraform-state"    
    key            = "global/s3/terraform.tfstate"    
    region         = "eu-west-2"
    # Замените это именем своей таблицы DynamoDB!
    dynamodb_table = "jiraiya106-terraform-state-locks"    
    encrypt        = true  
  }
}