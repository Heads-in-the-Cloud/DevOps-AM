
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region      = "us-west-2"
  profile     = "am_aws"
}

#############
# S3 Bucket #
#############

resource "aws_s3_bucket" "backend-bucket" {
  bucket  = "AM-Utopia-TF-backend-store"
  acl     = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name          = "AM-Utopia-TF-backend-store"
    Environment   = "Dev"
  }
}

##############
# State Lock #
##############

resource "aws_dynamodb_table" "db_terraform_state_lock" {
  name            = "AM-Utopia-TF-state-lock"
  hash_key        = "LockID"
  read_capacity   = 20
  write_capacity  = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}
