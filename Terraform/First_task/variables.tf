variable "access_key" {
  description = "Access key"
  type        = string
}

variable "secret_key" {
  description = "Secret key"
  type        = string
}

variable "region" {
  description = "Region"
  default     = "eu-west-2"
}

variable "common-tags" {
  description = "Name instance"
  type        = map
  default = {
    Name      = "My instance"
  }
}

variable "allow_port_app" {
  description = "Open port for App"
  type        = list
  default     = ["80", "443"]
}

variable "allow_port_alb" {
  description = "Open port for App"
  type        = list
  default     = ["80", "443"]
}


variable "allow_port_db" {
  description = "Open port for DB"
  type        = list
  default     = ["3306"]
}

variable "db_username" {
  description = "DB name"
  default     = ""
}

variable "db_password" {
  description = "DB password"
  default     = ""
}

variable db_name {
  description = "db name"
  default = "mydb"
}

variable "environment" {
  description = "environment"
  default     = "My terraform"
}

variable "vpc_cidr" {
  description = "VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "public"
  type        = list
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnets_cidr" {
  description = "private"
  type        = list
  default     = ["10.0.2.0/24"]
}

variable ssh_key {
  default     = "~/.ssh/id_rsa.pub"
  description = "Default pub key"
}

variable ssh_priv_key {
  default     = "~/.ssh/id_rsa"
  description = "Default private key"
}

variable "ssh_public_key" {
  description = "ssh_public_key"
  default     = ""
}

variable "env" {
  type = string
  default = ""
}