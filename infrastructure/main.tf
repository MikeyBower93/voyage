provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

# Creation of the elixir backends
module "apollo_backend" {
  source = "./modules/aws-elixir-ecs-backend"

  service_name       = "apollo"
}

module "foo_backend" {
  source = "./modules/aws-elixir-ecs-backend"

  service_name       = "foo"
}
