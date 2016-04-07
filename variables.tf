variable "aws_access_key" {
  description = "The AWS access key."
}

variable "aws_secret_key" {
  description = "The AWS secret key."
}

variable "region" {
  description = "The AWS region to create resources in."
  default = "us-east-1"
}

variable "availability_zones" {
  description = "The availability zone"
  default = "us-east-1b"
}

variable "vpc_subnet_availability_zone" {
  description = "The VPC subnet availability zone"
  default = "us-east-1b"
}

variable "ecs_cluster_name" {
  description = "The name of the Amazon ECS cluster."
  default = "weave-demo"
}

variable "amis" {
  description = "Weave AMIs. The latest AMIs can be found at https://raw.githubusercontent.com/weaveworks/integrations/master/aws/ecs/README.md"
  default = {
    us-east-1 = "ami-d49aa0be"
    us-west-1 = "ami-2f51224f"
    us-west-2 = "ami-1e28c77e"
    eu-west-1 = "ami-1dc1796e"
    eu-central-1 = "ami-d6c92db9"
    ap-northeast-1 = "ami-e9575987"
    ap-southeast-1 = "ami-4e36fe2d"
    ap-southeast-2 = "ami-e7e2c384"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}

variable "scope_aas_probe_token" {
  default = ""
  description = "Weave Scope token"
}
