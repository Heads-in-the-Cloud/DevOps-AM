
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

##############
# Networking #
##############

resource "aws_route53_record" "api_standalone_record" {
  zone_id = var.r53_zone_id
  name = var.endpoint
  type = "A"
  ttl = 60
  records = aws_instance.api_instance.public_ip
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
