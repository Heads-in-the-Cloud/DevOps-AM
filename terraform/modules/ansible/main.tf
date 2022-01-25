
##############
# Networking #
##############

resource "aws_route53_record" "api_standalone_record" {
  zone_id = var.r53_zone_id
  name = var.endpoint
  type = "CNAME"
  ttl = 60
  records = ["placeholder.text"]
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
