# ECS + Weave + Terraform Microservice Demo

This repo contains a [Terraform](https://terraform.io/) module for provisioning an [AWS ECS](https://aws.amazon.com/ecs/) cluster with [Weave Net](https://www.weave.works/products/weave-net/) as described in this blog post: [The fastest path to Docker on ECS: microservice deployment on Amazon EC2 Container Service with Weave Net](https://www.weave.works/guides/service-discovery-and-load-balancing-with-weave-on-amazon-ecs-2/).

Run it using this command:

```bash
terraform apply -var 'aws_access_key={your_aws_access_key}' \
   -var 'aws_secret_key={your_aws_secret_key}' -var 'key_name={your_keypair_name}'
```

**Note:** Make sure the keypair exists in the region configured (see variables.tf).
