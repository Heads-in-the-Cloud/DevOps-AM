
#############
# S3 Bucket #
#############

resource "aws_s3_bucket" "backend-bucket" {
  bucket  = "${var.environment_name}-backend-store"
  acl     = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name          = "${var.environment_name}-backend-store"
    Environment   = var.deploy_mode
  }
}

terraform {
  backend "s3" {
    bucket  = aws_s3_bucket.backend-bucket.bucket
    encrypt = true
    key     = "terraform.tfstate"
    region  = var.region
    profile = "am_aws"
  }
}
