variable "service_name" {
  default = "apollo"
}
variable "region" {}
variable "database_password" {
  sensitive = true
}
variable "secret_key_base" {
  sensitive = true
}