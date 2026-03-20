resource "aws_secretsmanager_secret" "config" {
  name = "ai-agent-config"
}

resource "aws_secretsmanager_secret_version" "config_value" {
  secret_id = aws_secretsmanager_secret.config.id

  secret_string = jsonencode({
    OPENSEARCH_ENDPOINT = "https://your-private-opensearch-endpoint"
  })
}