terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.27"
		}
	}

	required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region = "us-west-2"
}

module "user_directory" {
  source = "./user_directory"
}

module "session_service" {
	source = "./session_service"
}

output "cognito_user_pool_name" {
  value = module.user_directory
}

output "session_service_dynamodb_table" {
	value = module.session_service
}
