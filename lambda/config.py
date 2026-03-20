import boto3, json

def get_config():
    client = boto3.client("secretsmanager")
    res = client.get_secret_value(SecretId="ai-agent-config")
    return json.loads(res["SecretString"])