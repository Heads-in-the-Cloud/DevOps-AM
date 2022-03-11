
#############
# Providers #
#############

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.REGION_ID
  profile = "am_aws"
}

#######################
# Kubernetes Provider #
#    (not in use)     #
#######################

data "aws_eks_cluster" "cluster-id" {
  name = module.eks.eks_id
}

data "aws_eks_cluster_auth" "cluster-auth" {
  name = module.eks.eks_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster-id.endpoint
  token                  = data.aws_eks_cluster_auth.cluster-auth.token
  cluster_ca_certificate = base64encode(data.aws_eks_cluster.cluster-id.certificate_authority[0].data)
}

###########
# BACKEND #
###########

terraform {
  backend "s3" {
    bucket          = "am-utopia-tf-dev-backend-store"
    dynamodb_table  = "am-utopia-tf-dev-state-lock"
    encrypt         = true
    key             = "terraform.tfstate"
    region          = "us-west-1"
    profile         = "am_aws"
  }
}
