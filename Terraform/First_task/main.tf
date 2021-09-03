
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}
