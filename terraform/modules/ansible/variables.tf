variable "ami_id" {
  type = string
  default = ""
}

variable "instance_type" {
  type = string
  default = ""
}

variable "public_subnet_id" {
  type = string
  default = ""
}

variable "ssh_keyname" {
  type = string
  default = ""
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "r53_zone_id" {
  type = string
  default = ""
}

variable "endpoint" {
  type = string
  default = ""
}
