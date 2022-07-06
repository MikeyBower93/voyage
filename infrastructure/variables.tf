variable "region" {
  default = "eu-west-2"
}
variable "apollo_database_url" {
  sensitive = true
}
variable "apollo_secret_key_base" {
  sensitive = true
}