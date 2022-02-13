
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

variable "environment_name" {
  type = string
}

variable "deploy_mode" {
  type = string
}

##############
# Instancing #
##############

variable "node_instance_type" {
  type = string
  default = "t3.medium"
}
