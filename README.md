# Voyage

## Introduction
This is a project to demonstrate how to use terraform to create the following:
- An ECS cluster
- ECS services with AWS Service Discovery to enable Elixir clustering
- Load balanced for public traffic to the ECS services

It also demonstrates a mono repo approach, so if you created another elixir service you could easily terraform it, and also utilise a shared GitHub actions filed for CI/CD deployment to the cluster

To follow:
- Frontend stored and served from an S3 bucket
- Postgres per backend service
- RabbitMQ for message brokers

## Directory structure
- `voyage` - this is the root repo, this is the base mono repo, and is called `voyage` as this demo will be a basic travel booking site
- `infrastructure` - this is the terraform IaC for AWS provisioning
- `apollo` - this is just a name for one of the elixir backends created (I wanted to name give it a unique name to allow for other service creations in the future)

## Appendix
- [Deploying elixir on ECS](https://silbernagel.dev/posts/deploying-elixir-on-ecs-part-1/)