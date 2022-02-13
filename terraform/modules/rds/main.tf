
// AWS RDS Instance
resource "aws_db_instance" "rds" {
  allocated_storage     = 20
  engine                = var.db_engine
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  name                  = var.db_name
  username              = var.db_username
  password              = var.db_password
  db_subnet_group_name  = var.subnet_group_id
  vpc_security_group_ids = [var.rds_sg_id]
  skip_final_snapshot   = true
  tags = {
    Name = "AM-terraform-db"
  }
}
