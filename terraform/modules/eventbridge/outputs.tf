# modules/eventbridge/outputs.tf
output "event_rule_arn" {
  value = aws_cloudwatch_event_rule.this.arn
}

output "event_rule_name" {
  value = aws_cloudwatch_event_rule.this.name
}
