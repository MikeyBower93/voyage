provider "aws" {
  profile = "default"
  region  = var.region
}

module "apollo" {
  source = "./modules/apollo"
  region = var.region
  database_url = var.apollo_database_url
  secret_key_base = var.apollo_secret_key_base
}
