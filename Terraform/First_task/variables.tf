
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
  default = "eu-central-1"
}

variable "common-tags" {
  description = "Name instance"
  type = map
  default = {
    Name = "My instance"
  }
}

variable "allow_port_app" {
  description = "Open port for App"
  type = list
  default = ["80", "443"]
}

variable "allow_port_db" {
  description = "Open port for DB"
  type = list
  default = ["3306"]
}

variable "db_username" {
  description = "DB name"
  default = ""
}

variable "db_password" {
  description = "DB password"
  default = ""
}