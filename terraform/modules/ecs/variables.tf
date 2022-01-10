
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
