resource "aws_ecr_repository" "repo" {
  name                 = "${var.service_name}-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
