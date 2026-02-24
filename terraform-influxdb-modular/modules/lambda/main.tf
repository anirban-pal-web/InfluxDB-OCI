resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-dr-restore-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_lambda_function" "restore" {
  function_name = "influxdb-dr-restore-${random_id.suffix.hex}"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.10"
  handler       = "lambda_restore.lambda_handler"
  filename      = "${path.root}/lambda_restore.zip"

  environment {
    variables = {
      DR_INSTANCE_ID = var.dr_instance_id
      BUCKET         = var.bucket_name
    }
  }
}

