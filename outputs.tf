output "aws_instances_external" {
  value = "[ ${aws_elb.demo-elb.dns_name} ]"
}