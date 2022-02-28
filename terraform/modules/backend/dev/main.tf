
#############
# S3 Bucket #
#############

resource "aws_s3_bucket" "backend-bucket" {
  bucket  = "am-utopia-tf-dev-backend-store"
  acl     = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name          = "am-utopia-tf-dev-backend-store"
    Environment   = "Dev"
  }
  lifecycle {
    prevent_destroy = true
  }
}

##############
# State Lock #
##############

resource "aws_dynamodb_table" "db_terraform_state_lock" {
  name            = "am-utopia-tf-dev-state-lock"
  hash_key        = "LockID"
  read_capacity   = 20
  write_capacity  = 20
  attribute {
    name = "LockID"
    type = "S"
  }
  lifecycle {
    prevent_destroy = true
  }
}
