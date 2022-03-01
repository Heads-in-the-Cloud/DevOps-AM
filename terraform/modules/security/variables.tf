
variable "vpc_id" {
  type    = string
  default = ""
}

variable "deploy_mode" {
  type    = string
  default = "dev"
}

variable "environment_name" {
  type    = string
  default = ""
}

variable "private_cidrs" {
  type = list(string)
}

variable "public_cidrs" {
  type = list(string)
}
