resource "aws_cloudwatch_metric_alarm" "primary_down" {
  alarm_name          = "primary-influx-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1

  dimensions = {
    InstanceId = module.primary_ec2.instance_id
  }

  alarm_actions = [
    module.lambda_restore.lambda_arn
  ]
}

