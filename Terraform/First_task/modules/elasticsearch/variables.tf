variable "domain_name" {
    type = string
}
variable "instance_type" {
    type = string
}
variable "tag_domain" {
    type = string
}
variable "volume_type" {
    type = string
}
variable "access_key" {
  description = "Access key"
  type        = string
}
variable "secret_key" {
  description = "Secret key"
  type        = string
}
variable "vpc_cidr" {
  description = "VPC"
  default     = "10.0.0.0/16"
}
variable "public_subnets_cidr" {
  description = "public"
  type        = list
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "region" {
  description = "Region"
  default     = "eu-west-2"
}
variable "instance_count" {
    type = string
    default = "1"
}
variable "ebs_volume_size" {}