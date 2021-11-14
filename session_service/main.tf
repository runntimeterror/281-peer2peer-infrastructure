resource "aws_dynamodb_table" "user_session_table" {
  name = "${terraform.workspace}-user-session-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "SessionID"

  attribute {
    name = "SessionID"
    type = "S"
  }

  attribute {
    name = "ToUserID"
    type = "S"
  }
  
  attribute {
    name = "FromUserID"
    type = "S"
  }

  global_secondary_index {
    name = "SessionIDIndex"
    hash_key = "SessionID"
    write_capacity = 1
    read_capacity = 1
    projection_type = "KEYS_ONLY"
  }

  global_secondary_index {
    name = "ToUserIDIndex"
    hash_key = "ToUserID"
    write_capacity = 1
    read_capacity = 1
    projection_type = "KEYS_ONLY"
  }

  global_secondary_index {
    name = "FromUserIDIndex"
    hash_key = "FromUserID"
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

output "table_arn" {
  value = aws_dynamodb_table.user_session_table.arn
}