
############
# INSTANCE #
############

data "aws_ami" "linux" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "bastion" {
  // general info
  ami                         = data.aws_ami.linux.id
  instance_type               = var.bastion_instance_type
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_id
  key_name                    = var.bastion_ssh_keyname
  vpc_security_group_ids      = [aws_security_group.bastion_security.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  tags = { Name               = "AM-bastion" }

  // startup script
  user_data                   = templatefile("${path.module}/bastion_init.sh", {
    DB_ENDPOINT   = aws_db_instance.rds.address
    DB_USERNAME   = var.db_username
    DB_PASSWORD   = var.db_password
  })

  lifecycle {
    ignore_changes = [ associate_public_ip_address ]
  }
}

############
# Security #
############

resource "aws_security_group" "bastion_security" {
  name = "AM-bastion-security"
  description = "Allow only SSH"
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
