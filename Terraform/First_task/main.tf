terraform {
  required_version = "> 0.9.0"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "elasticache" {
    source                          = "./modules/elasticache"
    name                            = "Elasticache-test"
    region                          = "us-east-1"
    environment                     = "PROD"

    # NOTE: ElastiCache Subnet Groups are only for use when working with an ElastiCache cluster inside of a VPC. If you are on EC2 Classic, see the ElastiCache Security Group resource.
    # NOTE: ElastiCache Security Groups are for use only when working with an ElastiCache cluster outside of a VPC. If you are using a VPC, see the ElastiCache Subnet Group resource.
    # I HAVE GOT ISSUE WHEN USED "ElastiCache Security Groups". SO I PREFERED ElastiCache Subnet Groups
    #aws_elasticache_security_group.elasticache_sg: Error creating CacheSecurityGroup: InvalidParameterValue: Use of cache security groups is not permitted in this API version for your account.
    security_group_names    = [aws_security_group.default.id]
    subnet_ids              = [aws_subnet.public_subnet.*.id]

    create_custom_elasticache_parameter_group   = true
    parameters_for_parameter_group              = [
    {
        name  = "activerehashing"
        value = "yes"
    },
    {
        name  = "min-slaves-to-write"
        value = "2"
    },
    ]
    engine                                      = "redis" #"memcached"

    # Not single cluster
    #create_single_cluster   = false
    #num_cache_nodes         = 2
    #number_cluster_replicas = 1
    #node_type               = "cache.m3.medium"

    # cluster with 2 nodes and 2 shards
    create_single_cluster   = false
    number_cluster_replicas = 2
    num_cache_nodes         = 2
    node_type               = "cache.m3.medium"
    parameter_group_name    = [{
        redis   = "default.redis3.2.cluster.on"
    }]

}