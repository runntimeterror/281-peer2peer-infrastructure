resource "aws_cognito_user_pool" "pool" {
  name = "${terraform.workspace}-chatuserpool"
}