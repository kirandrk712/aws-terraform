output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "artifacts_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "alerts_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "ssm_connect_command" {
  value = "aws ssm start-session --target ${aws_instance.web.id} --region ${var.region}"
}
