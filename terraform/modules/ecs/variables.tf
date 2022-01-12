
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

#################
# ECS Variables #
#################

variable "task_arn" {
  type = string
  default = ""
}

variable "net_mode" {
  type = string
  default = "awsvpc"
}

variable "memory" {
  type = number
  default = 1024
}

variable "cpu" {
  type = number
  default = 512
}

#################
# ECR Variables #
#################

variable "flights-repo" {
  type = string
  default = ""
}

variable "users-repo" {
  type = string
  default = ""
}

variable "bookings-repo" {
  type = string
  default = ""
}

variable "auth-repo" {
  type = string
  default = ""
}

variable "environment" {
  type = list(map(string))
  default = []
}

variable "desired-container-count" {
  type = number
  default = 1
}

##################
# Defined Locals #
##################

locals {
  indexes = {"flights": 8081, "users": 8083, "bookings": 8082, "auth": 8443}
  repos = {"flights": var.flights-repo, "users": var.users-repo, "bookings": var.bookings-repo, "auth": var.auth-repo}
}
