data "aws_subnet_ids" "vpc" {
  vpc_id = aws_default_vpc.default_vpc.id
}
data "aws_caller_identity" "current" {}