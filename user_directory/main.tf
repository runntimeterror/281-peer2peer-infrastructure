data "aws_cognito_user_pools" "moochat_users" {
  name = "${terraform.workspace}-moochat-users"
}

output "user_pool_name" {
  value = data.aws_cognito_user_pools.moochat_users.arns
}