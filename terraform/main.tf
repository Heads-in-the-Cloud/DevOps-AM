
data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = "dev/AM/utopia-secrets"
}

data "aws_ecr_repository" "ecr-flights" {
  name = "am-flights-api"
}

data "aws_ecr_repository" "ecr-users" {
  name = "am-users-api"
}

data "aws_ecr_repository" "ecr-bookings" {
  name = "am-bookings-api"
}

data "aws_ecr_repository" "ecr-auth" {
  name = "am-auth-api"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.secrets.secret_string
  )
  zone_id = "Z02774322V8FI017JONWO"
  api_endpoint = "am-api.hitwc.link"
}

resource "aws_key_pair" "bastion_key" {
  key_name = "bastion_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClX+8jDnS03TezMz3AWki1+FkOwcSdTxTtj40gbYf8ysf6Aa5VCWZBkzHEfmGo+mMBgfu3N3QDvRz+rR5RrOOsOfKPcFOY5jnHImZeoLaAMbD0Qvk9cyUG7/ndkz/puYd/DNPvP6R/jyHvNiDeK0yVSoGAPLybzI4GVmpnO/FTK8uGsJsxuXUVpt5H0MZ/Sl9eGUkzrXQIFGVS4Anj0532/5xvY4DX3B8ahOgomFCLED66ZAheWMfq0R/q06MSP2TOMV7Fna2uKchwHyNYDjh+hEVCw554LE42lQgtb70oP0fGEWAYFBeNFF2aOWw389n+zqwDgBHCnGHDQj83e//MYsomApuKK8etYrY4BhB53VXe8R5nNY3CfkXmPFwJxUojfFFgGf+XF9kbDK1lSUT/7+HynmrPG4LYTBpQvm4OmhEDABqLXctb0hasnEkZjXoJ7dSxjf2kMTZZcqGOk+5GKi+6vfmql80k3LaON1DYYxr9qniD3dMoLG77qPs0DiLXMxAcH4y5+Rz+4oE11dO5yfypRfevYMLpRVcMI4/mgh5Knu3PvSkFR2ltQXyY266LEjT6G+feZOBWdev797QQLxo2vyBk7NtnBDA7GQfuhaKhFAAavJ2Wz+aXnNLYVDP0jP5g/abbgE1saU4LhiIj8meyN9ViBEKDLdggY6UhAQ== aidan.mattson@smoothstack.com"
}

module "network" {
  source                      = "./modules/network"
  vpc_cidr                    = "10.0.0.0/16"
  vpc_subnet_1_private_cidr   = "10.0.1.0/24"
  vpc_subnet_2_private_cidr   = "10.0.2.0/24"
  vpc_subnet_1_public_cidr    = "10.0.3.0/24"
  vpc_subnet_2_public_cidr    = "10.0.4.0/24"
  route_cidr                  = "0.0.0.0/0"
  zone_1                      = "us-west-2a"
  zone_2                      = "us-west-2b"
}

module "utopia-db" {
  source                = "./modules/rds"
  db_instance_class     = "db.t3.small"
  db_name               = "amUtopiaDB"
  db_engine             = "mysql"
  db_engine_version     = "8.0.23"
  subnet_group_id       = module.network.subnet_group_id
  public_subnet_id      = module.network.all_subnets[2]
  vpc_id                = module.network.utopia_vpc
  db_username           = local.db_creds.DB_USERNAME
  db_password           = local.db_creds.DB_PASSWORD
  ami_id                = "ami-00f7e5c52c0f43726"
  bastion_ssh_keyname   = aws_key_pair.bastion_key.key_name
}

module "ecs" {
  source          = "./modules/ecs"
  r53_zone_id     = local.zone_id
  vpc_id          = module.network.utopia_vpc
  service_subnets = [module.network.all_subnets[2]]
}

module "eks" {
  source              = "./modules/eks"
  eks_public_subnets  = [module.network.all_subnets[2], module.network.all_subnets[3]]
  eks_subnets         = module.network.all_subnets
  vpc_id              = module.network.utopia_vpc
  r53_zone_id         = local.zone_id
  node_instance_type  = "t3.small"
}

//module "ansible" {
//  source                = "./modules/ansible"
//  ami_id                = "ami-066333d9c572b0680"
//  instance_type         = "t2.medium"
//  public_subnet_id      = module.network.all_subnets[3]
//  ssh_keyname           = aws_key_pair.bastion_key.key_name
//  vpc_id                = module.network.utopia_vpc
//  r53_zone_id           = local.zone_id
//  endpoint              = local.api_endpoint
//}

resource "local_file" "ansible_vars" {
  filename = "./tf_output_vars.yaml"
  content = <<-VARS
    TF_VPC_ID: ${module.network.utopia_vpc}
    TF_RDS_ENDPOINT: ${module.utopia-db.db_address}
    TF_ALB_ID: ${module.ecs.ALB_ID}
    TF_SUBNET_PUBLIC_1: ${module.network.all_subnets[3]}
  VARS
}
