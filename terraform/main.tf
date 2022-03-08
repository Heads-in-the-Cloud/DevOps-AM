#############
# RESOURCES #
#############

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = var.SSH_BASTION_KEY
}

locals {
  bastion_ami_tag  = "ami-00f7e5c52c0f43726"
  environment_name = "AM-Utopia-TF-${var.DEPLOY_MODE}"

  vpc_cidr                  = "10.0.0.0/16"
  vpc_subnet_1_private_cidr = "10.0.1.0/24"
  vpc_subnet_2_private_cidr = "10.0.2.0/24"
  vpc_subnet_1_public_cidr  = "10.0.3.0/24"
  vpc_subnet_2_public_cidr  = "10.0.4.0/24"
}

###########
# MODULES #
###########

module "network" {
  # general
  source           = "./modules/network"
  deploy_mode      = var.DEPLOY_MODE
  environment_name = local.environment_name

  # networking
  vpc_cidr                  = local.vpc_cidr
  vpc_subnet_1_private_cidr = local.vpc_subnet_1_private_cidr
  vpc_subnet_2_private_cidr = local.vpc_subnet_2_private_cidr
  vpc_subnet_1_public_cidr  = local.vpc_subnet_1_public_cidr
  vpc_subnet_2_public_cidr  = local.vpc_subnet_2_public_cidr
  route_cidr                = "0.0.0.0/0"
  zone_1                    = "${var.REGION_ID}${var.AZ_1}"
  zone_2                    = "${var.REGION_ID}${var.AZ_2}"
}


module "security" {
  # general
  source           = "./modules/security"
  deploy_mode      = var.DEPLOY_MODE
  environment_name = local.environment_name

  # networking info
  vpc_id        = module.network.utopia_vpc
  public_cidrs  = [ local.vpc_subnet_1_public_cidr,  local.vpc_subnet_2_public_cidr  ]
  private_cidrs = [ local.vpc_subnet_1_private_cidr, local.vpc_subnet_2_private_cidr ]
}


module "utopia-db" {
  # general
  source           = "./modules/rds"
  deploy_mode      = var.DEPLOY_MODE
  environment_name = local.environment_name

  # instancing
  db_instance_class = "db.t3.small"
  db_name           = "amUtopiaDB"
  db_engine         = "mysql"
  db_engine_version = "8.0.23"

  # networking
  subnet_group_id  = module.network.subnet_group_id
  public_subnet_id = module.network.public_subnets[0]
  vpc_id           = module.network.utopia_vpc
  rds_sg_id        = module.security.SG_RDS

  # database
  db_username = var.DB_USERNAME
  db_password = var.DB_PASSWORD

  # bastion host
  ami_id                = local.bastion_ami_tag
  bastion_ssh_keyname   = aws_key_pair.bastion_key.key_name
  bastion_instance_type = "t2.micro"
  bastion_sg_id         = module.security.SG_Bastion
}


module "ecs" {
  # general
  source           = "./modules/ecs"
  deploy_mode      = var.DEPLOY_MODE
  environment_name = local.environment_name

  # networking
  r53_zone_id     = var.HOSTED_ZONE
  record_name     = "${var.DEPLOY_MODE}-${var.ECS_RECORD}"
  vpc_id          = module.network.utopia_vpc
  service_subnets = module.network.public_subnets
  loadbalancer_sg = module.security.SG_ECS_LB
}


module "eks" {
  # general
  source           = "./modules/eks"
  deploy_mode      = var.DEPLOY_MODE
  environment_name = local.environment_name

  # networking
  eks_node_subnets = module.network.private_subnets
  eks_subnets        = concat(module.network.public_subnets, module.network.private_subnets)
  vpc_id             = module.network.utopia_vpc
  eks_sg_id          = module.security.SG_EKS
  r53_zone_id        = var.HOSTED_ZONE
  record_name        = "${var.DEPLOY_MODE}-${var.EKS_RECORD}"

  # instancing
  node_instance_type = "t3.medium"
}


###########
# OUTPUTS #
###########

//resource "local_file" "ansible_output_vars" {
//  filename = "${var.ANSIBLE_DIRECTORY}/vars/dynamic/tf_output_vars.yaml"
//  content = <<-VARS
//    aws_region: ${var.REGION_ID}
//    vpc_id: ${module.network.utopia_vpc}
//    subnet_private_1_id: ${module.network.all_subnets[0]}
//    subnet_private_2_id: ${module.network.all_subnets[1]}
//    subnet_public_1_id: ${module.network.all_subnets[2]}
//    subnet_public_2_id: ${module.network.all_subnets[3]}
//  VARS
//}
