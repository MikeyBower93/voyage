resource "aws_service_discovery_private_dns_namespace" "dns_namespace" {
  name        = "${var.service_name}.local"
  description = "Service discovery for elixir clustering"
  vpc         = aws_default_vpc.default_vpc.id
}

resource "aws_service_discovery_service" "service_discovery" {
  name = var.service_name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.dns_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}