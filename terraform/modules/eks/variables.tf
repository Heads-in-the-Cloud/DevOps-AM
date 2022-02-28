###########
# General #
###########

variable "environment_name" {
  type = string
}

variable "deploy_mode" {
  type = string
}

##############
# Networking #
##############

variable "eks_subnets" {
  type = list(string)
  default = []
}

variable "eks_public_subnets" {
  type = list(string)
  default = []
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "eks_sg_id" {
  type = string
  default = ""
}

variable "r53_zone_id" {
  type = string
  default = ""
}

variable "record_name" {
  type = string
  default = ""
}

##############
# Instancing #
##############

variable "node_instance_type" {
  type = string
  default = "t3.medium"
}
