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
  region = "us-east-1"
}

module "user_directory" {
  source = "./modules/user_directory"
}

module "socket_service" {
  source = "./modules/socket_service"
}

module "moochat_ui" {
  source = "./modules/moochat_ui"
}

output "cognito_user_pool_name" {
  value = module.user_directory
}

output "moochat_ui_deployment" {
  value = module.moochat_ui
}

output "socket_service" {
  value = module.socket_service
}
