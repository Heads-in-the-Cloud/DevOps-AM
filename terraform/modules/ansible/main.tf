
################
# EC2 Instance #
################

resource "aws_instance" "api_instance"{
  // general info
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_id
  key_name                    = var.ssh_keyname
  vpc_security_group_ids      = [aws_security_group.api_instance_security.id]

  // additional
  tags = {
    Name = "AM-api-host"
  }
}

############
# Security #
############

resource "aws_security_group" "api_instance_security" {
  name = "AM-api-instance-security"
  description = "Allow nginx and SSH traffic only"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "AM-api-instance-security"
  }
}
