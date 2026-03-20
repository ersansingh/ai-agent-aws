############################################
# Provider
############################################
provider "aws" {
  region = var.region
}

############################################
# IAM Role for Lambda
############################################
resource "aws_iam_role" "lambda_role" {
  name = "ai-agent-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

############################################
# IAM Policy (Least Privilege)
############################################
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["bedrock:InvokeModel"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem"]
        Resource = aws_dynamodb_table.memory.arn
      },
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = aws_secretsmanager_secret.config.arn
      },
      {
        Effect = "Allow"
        Action = ["logs:*"]
        Resource = "*"
      }
    ]
  })
}

############################################
# DynamoDB (Memory)
############################################
resource "aws_dynamodb_table" "memory" {
  name         = "agent-memory-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

############################################
# Lambda Function (Versioned)
############################################
resource "aws_lambda_function" "agent" {
  function_name = "ai-agent-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "agent.handler"
  runtime       = "python3.10"

  filename         = "../lambda.zip"
  source_code_hash = filebase64sha256("../lambda.zip")

  publish = true

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.memory.name
      SECRET_ID  = aws_secretsmanager_secret.config.name
    }
  }

  ##########################################
  # VPC Integration (from network.tf)
  ##########################################
  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [
    aws_secretsmanager_secret.config
  ]
}

############################################
# Lambda Alias (Live Traffic)
############################################
resource "aws_lambda_alias" "live" {
  name             = "live"
  function_name    = aws_lambda_function.agent.function_name
  function_version = aws_lambda_function.agent.version
}

############################################
# CodeDeploy Role
############################################
resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codedeploy.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codedeploy_policy" {
  role = aws_iam_role.codedeploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "*"
      Resource = "*"
    }]
  })
}

############################################
# CodeDeploy Application
############################################
resource "aws_codedeploy_app" "app" {
  name             = "ai-agent-app-${var.environment}"
  compute_platform = "Lambda"
}

############################################
# CodeDeploy Deployment Group (Blue/Green + Rollback)
############################################
resource "aws_codedeploy_deployment_group" "group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "ai-agent-group-${var.environment}"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.LambdaCanary10Percent5Minutes"

  ##########################################
  # Auto Rollback
  ##########################################
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  ##########################################
  # Alarm (from monitoring.tf)
  ##########################################
  alarm_configuration {
    alarms  = [aws_cloudwatch_metric_alarm.lambda_errors.name]
    enabled = true
  }

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }
}

############################################
# API Gateway
############################################
resource "aws_apigatewayv2_api" "api" {
  name          = "agent-api-${var.environment}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  # ✅ Use alias (Blue/Green works here)
  integration_uri = aws_lambda_alias.live.invoke_arn
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /agent"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}