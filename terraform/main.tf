
#############
# RESOURCES #
#############

data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = "dev/AM/utopia-secrets"
}

resource "aws_key_pair" "bastion_key" {
  key_name = "bastion_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClX+8jDnS03TezMz3AWki1+FkOwcSdTxTtj40gbYf8ysf6Aa5VCWZBkzHEfmGo+mMBgfu3N3QDvRz+rR5RrOOsOfKPcFOY5jnHImZeoLaAMbD0Qvk9cyUG7/ndkz/puYd/DNPvP6R/jyHvNiDeK0yVSoGAPLybzI4GVmpnO/FTK8uGsJsxuXUVpt5H0MZ/Sl9eGUkzrXQIFGVS4Anj0532/5xvY4DX3B8ahOgomFCLED66ZAheWMfq0R/q06MSP2TOMV7Fna2uKchwHyNYDjh+hEVCw554LE42lQgtb70oP0fGEWAYFBeNFF2aOWw389n+zqwDgBHCnGHDQj83e//MYsomApuKK8etYrY4BhB53VXe8R5nNY3CfkXmPFwJxUojfFFgGf+XF9kbDK1lSUT/7+HynmrPG4LYTBpQvm4OmhEDABqLXctb0hasnEkZjXoJ7dSxjf2kMTZZcqGOk+5GKi+6vfmql80k3LaON1DYYxr9qniD3dMoLG77qPs0DiLXMxAcH4y5+Rz+4oE11dO5yfypRfevYMLpRVcMI4/mgh5Knu3PvSkFR2ltQXyY266LEjT6G+feZOBWdev797QQLxo2vyBk7NtnBDA7GQfuhaKhFAAavJ2Wz+aXnNLYVDP0jP5g/abbgE1saU4LhiIj8meyN9ViBEKDLdggY6UhAQ== aidan.mattson@smoothstack.com"
}

locals {
  db_creds          = jsondecode(
    data.aws_secretsmanager_secret_version.secrets.secret_string
  )
  bastion_ami_tag   = "ami-00f7e5c52c0f43726"
}


###########
# MODULES #
###########

module "network" {
  source                      = "./modules/network"

  # networking
  vpc_cidr                    = "10.0.0.0/16"
  vpc_subnet_1_private_cidr   = "10.0.1.0/24"
  vpc_subnet_2_private_cidr   = "10.0.2.0/24"
  vpc_subnet_1_public_cidr    = "10.0.3.0/24"
  vpc_subnet_2_public_cidr    = "10.0.4.0/24"
  route_cidr                  = "0.0.0.0/0"
  zone_1                      = "${var.REGION_ID}a"
  zone_2                      = "${var.REGION_ID}b"
}

module "utopia-db" {
  source                = "./modules/rds"

  # instancing
  db_instance_class     = "db.t3.small"
  db_name               = "amUtopiaDB"
  db_engine             = "mysql"
  db_engine_version     = "8.0.23"

  # networking
  subnet_group_id       = module.network.subnet_group_id
  public_subnet_id      = module.network.all_subnets[2]
  vpc_id                = module.network.utopia_vpc

  # database
  db_username           = local.db_creds.DB_USERNAME
  db_password           = local.db_creds.DB_PASSWORD

  # bastion host
  ami_id                = local.bastion_ami_tag
  bastion_ssh_keyname   = aws_key_pair.bastion_key.key_name
  bastion_instance_type = "t2.micro"
}

module "ecs" {
  source          = "./modules/ecs"

  # networking
  r53_zone_id     = var.HOSTED_ZONE
  record_name     = var.ECS_RECORD
  vpc_id          = module.network.utopia_vpc
  service_subnets = [module.network.all_subnets[2]]

}

module "eks" {
  source              = "./modules/eks"

  # networking
  eks_public_subnets  = [module.network.all_subnets[2], module.network.all_subnets[3]]
  eks_subnets         = module.network.all_subnets
  vpc_id              = module.network.utopia_vpc
  r53_zone_id         = var.HOSTED_ZONE
  record_name         = var.EKS_RECORD

  # instancing
  node_instance_type  = "t3.small"
}


###########
# OUTPUTS #
###########

resource "local_file" "ansible_eks_vars" {
  filename = "outputs/eks_output_vars.yaml"
  content = <<-VARS
    tf_subnet_public_1: ${module.network.all_subnets[2]}
    tf_subnet_public_2: ${module.network.all_subnets[3]}
    tf_eks_iam_role_arn: ${module.eks.iam_role_arn}
  VARS
}

//resource "local_file" "ansible_ec2_vars" {
//  filename = "${AM_ANSIBLE_DIRECTORY}/vars/dynamic/ec2/tf_output_vars.yaml"
//  content = <<-VARS
//    var: val
//  VARS
//}
