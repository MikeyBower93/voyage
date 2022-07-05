provider "aws" {
  profile = "default"
  region  = var.region
}

# Creation of the elixir backends
module "apollo_backend" {
  source = "./modules/aws-elixir-ecs-backend"

  service_name = "apollo"
  region       = var.region
}
