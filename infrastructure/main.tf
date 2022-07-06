provider "aws" {
  profile = "default"
  region  = var.region
}

module "apollo" {
  source            = "./modules/apollo"
  region            = var.region
  database_password = var.apollo_database_password
  secret_key_base   = var.apollo_secret_key_base
}
