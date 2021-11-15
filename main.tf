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

output "cognito_user_pool_name" {
  value = module.user_directory
}
