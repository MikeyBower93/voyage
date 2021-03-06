# Voyage

## Introduction
This is a project to demonstrate how to use terraform to create the following:
- ECS cluster
- ECS services with AWS Service Discovery to enable Elixir clustering
- Load balancer for public traffic to the ECS services
- Postgres RDS within the VPC
- A react frontend hosted on S3

It also demonstrates a mono repo approach, so if you created another elixir service you could easily terraform it, and also utilise a shared GitHub actions files for CI/CD deployment to the cluster/s3 buckets

## Directory structure
- `voyage` - this is the root repo, this is the base mono repo, and is called `voyage` as this demo will demonstrate a basic travel/holiday site (where you can travel to planets)
- `infrastructure` - this is the terraform IaC for AWS provisioning
- `apollo` - this is just a name for one of the elixir backends created (I wanted to name give it a unique name to allow for other service creations in the future to have a semi "micro-service" approach)
- `houston` -  this is a baic react frontend that gets hosted in S3 which calls the `apollo` Rest API

## Caveats
- This doesn't create a DNS entry or HTTPs as it was out of scope of this learning process
- This also doesn't create RDS backups

## Appendix
- [Deploying elixir on ECS](https://silbernagel.dev/posts/deploying-elixir-on-ecs-part-1/)
