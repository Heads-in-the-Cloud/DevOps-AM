
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

variable "r53_zone_id" {
  type = string
  default = ""
}
