import boto3, json

bedrock = boto3.client("bedrock-runtime")

def call_llm(prompt):
    res = bedrock.invoke_model(
        modelId="anthropic.claude-v2",
        body=json.dumps({"prompt": prompt, "max_tokens_to_sample": 200})
    )
    return json.loads(res["body"].read())

def run_multi_agent(query):
    plan = call_llm(f"Break into steps: {query}")
    exec_result = call_llm(f"Execute: {plan}")
    final = call_llm(f"Improve: {exec_result}")
    return final