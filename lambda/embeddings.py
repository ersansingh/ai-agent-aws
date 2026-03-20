import boto3, json

bedrock = boto3.client("bedrock-runtime")

def generate_embedding(text):
    res = bedrock.invoke_model(
        modelId="amazon.titan-embed-text-v1",
        body=json.dumps({"inputText": text})
    )
    return json.loads(res["body"].read())["embedding"]