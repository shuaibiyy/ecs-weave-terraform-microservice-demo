provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "weave-demo" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

# availability zone.
resource "aws_subnet" "weave-demo" {
  vpc_id = "${aws_vpc.weave-demo.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.vpc_subnet_availability_zone}"
}

resource "aws_internet_gateway" "weave-demo" {
  vpc_id = "${aws_vpc.weave-demo.id}"
}

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.weave-demo.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.weave-demo.id}"
  }
  depends_on = ["aws_internet_gateway.weave-demo"]
}

resource "aws_route_table_association" "external" {
  subnet_id = "${aws_subnet.weave-demo.id}"
  route_table_id = "${aws_route_table.external.id}"
}

resource "aws_security_group" "load_balancers" {
  name = "load_balancers"
  description = "Allows all traffic"
  vpc_id = "${aws_vpc.weave-demo.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name = "ecs"
  description = "Allows certain traffic"
  vpc_id = "${aws_vpc.weave-demo.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 4040
    to_port = 4040
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  # ELB
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [
      "${aws_security_group.load_balancers.id}"]
  }

  # Weave
  ingress {
    from_port = 6783
    to_port = 6783
    protocol = "tcp"
    self = true
  }

  ingress {
    from_port = 6783
    to_port = 6783
    protocol = "udp"
    self = true
  }

  ingress {
    from_port = 6784
    to_port = 6784
    protocol = "udp"
    self = true
  }

  # Scope
  ingress {
    from_port = 4040
    to_port = 4040
    protocol = "tcp"
    self = true
  }
}

resource "aws_ecs_cluster" "weave-demo" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_iam_role" "weave_ecs_host_role" {
  name = "weave_ecs_host_role"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "weave_ecs_instance_role_policy" {
  name = "weave_ecs_instance_role_policy"
  policy = "${file("policies/ecs-instance-role-policy.json")}"
  role = "${aws_iam_role.weave_ecs_host_role.id}"
}

resource "aws_iam_role" "weave_ecs_service_role" {
  name = "weave_ecs_service_role"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "weave_ecs_service_role_policy" {
  name = "weave_ecs_service_role_policy"
  policy = "${file("policies/ecs-service-role-policy.json")}"
  role = "${aws_iam_role.weave_ecs_service_role.id}"
}

resource "aws_iam_instance_profile" "weave_ecs" {
  name = "weave-ecs-instance-profile"
  path = "/"
  roles = [
    "${aws_iam_role.weave_ecs_host_role.name}"]
}

resource "aws_autoscaling_group" "ecs-cluster" {
  name = "ECS ASG ${var.ecs_cluster_name}"
  min_size = 3
  max_size = 3
  desired_capacity = 3
  health_check_grace_period = 300
  health_check_type = "ELB"
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  availability_zones = ["${var.availability_zones}"]
  vpc_zone_identifier = [
    "${aws_subnet.weave-demo.id}"]
}

resource "aws_launch_configuration" "ecs" {
  name = "ECS LC ${var.ecs_cluster_name}"
  image_id = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  security_groups = [
    "${aws_security_group.ecs.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.weave_ecs.name}"
  key_name = "${var.key_name}"
  associate_public_ip_address = true
  user_data = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config\necho SERVICE_TOKEN='${var.scope_aas_probe_token}' > /etc/weave/scope.config"
}
