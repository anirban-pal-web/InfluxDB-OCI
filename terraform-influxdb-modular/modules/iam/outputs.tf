output "instance_profile_name" {
  value = aws_iam_instance_profile.profile.name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

