
#####################
# Network Variables #
#####################

variable "vpc_id" {
  type = string
  default = ""
}

variable "service_subnets" {
  type = list(string)
  default = []
}

variable "r53_zone_id" {
  type = string
  default = ""
}

variable "record_name" {
  type = string
  default = ""
}

variable "environment_name" {
  type = string
}

variable "deploy_mode" {
  type = string
}
