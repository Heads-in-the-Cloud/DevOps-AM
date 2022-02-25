
##############
# State Lock #
##############

resource "aws_dynamodb_table" "db_terraform_state_lock" {
  name            = "${var.environment_name}-state-lock"
  hash_key        = "LockID"
  read_capacity   = 20
  write_capacity  = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}
