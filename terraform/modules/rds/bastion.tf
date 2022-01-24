
resource "aws_instance" "bastion" {
  // general info
  ami                         = var.ami_id
  instance_type               = var.bastion_instance_type
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_id
  key_name                    = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_security.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  tags = { Name               = "AM-bastion" }

  // startup script
  user_data                   = templatefile("${path.module}/bastion_init.sh", {
    DB_ENDPOINT   = aws_db_instance.rds.address
    DB_USERNAME   = var.db_username
    DB_PASSWORD   = var.db_password
    DB_NAME       = var.db_name
  })
}

resource "aws_security_group" "bastion_security" {
  name = "AM-bastion-security"
  description = "Allow all SSH"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AM-bastion-security"
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name = var.bastion_ssh_keyname
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClX+8jDnS03TezMz3AWki1+FkOwcSdTxTtj40gbYf8ysf6Aa5VCWZBkzHEfmGo+mMBgfu3N3QDvRz+rR5RrOOsOfKPcFOY5jnHImZeoLaAMbD0Qvk9cyUG7/ndkz/puYd/DNPvP6R/jyHvNiDeK0yVSoGAPLybzI4GVmpnO/FTK8uGsJsxuXUVpt5H0MZ/Sl9eGUkzrXQIFGVS4Anj0532/5xvY4DX3B8ahOgomFCLED66ZAheWMfq0R/q06MSP2TOMV7Fna2uKchwHyNYDjh+hEVCw554LE42lQgtb70oP0fGEWAYFBeNFF2aOWw389n+zqwDgBHCnGHDQj83e//MYsomApuKK8etYrY4BhB53VXe8R5nNY3CfkXmPFwJxUojfFFgGf+XF9kbDK1lSUT/7+HynmrPG4LYTBpQvm4OmhEDABqLXctb0hasnEkZjXoJ7dSxjf2kMTZZcqGOk+5GKi+6vfmql80k3LaON1DYYxr9qniD3dMoLG77qPs0DiLXMxAcH4y5+Rz+4oE11dO5yfypRfevYMLpRVcMI4/mgh5Knu3PvSkFR2ltQXyY266LEjT6G+feZOBWdev797QQLxo2vyBk7NtnBDA7GQfuhaKhFAAavJ2Wz+aXnNLYVDP0jP5g/abbgE1saU4LhiIj8meyN9ViBEKDLdggY6UhAQ== aidan.mattson@smoothstack.com"
}
