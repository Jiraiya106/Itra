locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region      = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=17.19.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_id  = "fake-vpc-id"
    subnets = ["fake-subnet-id"]
  }
}

inputs = {
  cluster_name    = "eks-cluster-${local.env}"
  cluster_version = "1.21"

  vpc_id  = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.public_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  # worker_groups = [
  #   {
  #     name                          = "spot-group"
  #     instance_type                 = "t2.micro"
  #     spot_max_price                = "0.04"
  #     spot_price                    = "0.02"
  #     asg_desired_capacity          = 1
  #     asg_max_size                  = 1
  #     kubelet_extra_args            = "--node-labels=node.kubernetes.io/lifecycle=spot"
  #   },
  #   {
  #     name                 = "on-demand-group"
  #     instance_type        = "t2.micro"
  #     asg_desired_capacity = 1
  #     asg_max_size         = 1
  #     kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
  #   }
  # ]

    node_groups = {
    first = {
      name             = "example"
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "t2.micro"
    }
  }
}

generate "provider-local" {
  path      = "provider-local.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

    data "aws_eks_cluster" "eks" {
        name = aws_eks_cluster.this[0].id
    }

    data "aws_eks_cluster_auth" "eks" {
        name = aws_eks_cluster.this[0].id
    }

    provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  token                  = data.aws_eks_cluster_auth.eks.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
}

resource "kubernetes_namespace" "test" {
  metadata {
    name = "nginx"
  }
}
resource "kubernetes_deployment" "test" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "MyTestApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyTestApp"
        }
      }
      spec {
        container {
          image = "225050420367.dkr.ecr.us-west-2.amazonaws.com/task:nginxpy"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "test" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.test.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "app"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "MyApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyApp"
        }
      }
      spec {
        container {
          image = "225050420367.dkr.ecr.us-west-2.amazonaws.com/task:apppy"
          name = "app"
          port {
            container_port = 8000
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "app" {
  metadata {
    name      = "app"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 8000
      target_port = 8000
    }
  }
}
EOF
}
