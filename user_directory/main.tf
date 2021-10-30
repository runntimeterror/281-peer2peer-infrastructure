data "aws_cognito_user_pools" "p2pchatusers" {
  name = "${terraform.workspace}-p2pchatusers"
}

output "user_pool_name" {
  value = data.aws_cognito_user_pools.p2pchatusers.arns
}