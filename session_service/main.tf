resource "aws_dynamodb_table" "user_session_table" {
  name = "${terraform.workspace}-user-session-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "UserID"

  attribute {
    name = "UserID"
    type = "S"
  }

  attribute {
    name = "SessionID"
    type = "S"
  }

  global_secondary_index {
    name = "UserIDIndex"
    hash_key = "UserID"
    write_capacity = 1
    read_capacity = 1
    projection_type = "KEYS_ONLY"
  }

  global_secondary_index {
    name = "SessionIDIndex"
    hash_key = "SessionID"
    write_capacity = 1
    read_capacity = 1
    projection_type = "KEYS_ONLY"
  }

  tags = {
    Name = "${terraform.workspace}-files-dynamodb-table"
    Environment = "${terraform.workspace}"
  }
}

output "table_name" {
  value = aws_dynamodb_table.user_session_table.name
}
