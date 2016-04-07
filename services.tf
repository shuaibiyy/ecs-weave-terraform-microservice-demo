resource "aws_elb" "demo-elb" {
  name = "demo-elb"
  security_groups = ["${aws_security_group.load_balancers.id}"]
  subnets = ["${aws_subnet.weave-demo.id}"]

  listener {
    lb_protocol = "http"
    lb_port = 80

    instance_protocol = "http"
    instance_port = 80
  }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 5
    target = "HTTP:80/"
    interval = 30
  }

  cross_zone_load_balancing = true
}

resource "aws_ecs_task_definition" "demo-task" {
  family = "weave-demo"
  container_definitions = "${file("task-definitions/demo-task.json")}"
}

resource "aws_ecs_service" "demo-service" {
  name = "demo-service"
  cluster = "${aws_ecs_cluster.weave-demo.id}"
  task_definition = "${aws_ecs_task_definition.demo-task.arn}"
  iam_role = "${aws_iam_role.weave_ecs_service_role.arn}"
  desired_count = 3
  depends_on = ["aws_iam_role_policy.weave_ecs_service_role_policy"]

  load_balancer {
    elb_name = "${aws_elb.demo-elb.id}"
    container_name = "httpserver"
    container_port = 80
  }
}
