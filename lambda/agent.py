import json
from multi_agent import run_multi_agent
from rag import search_vector_db

def handler(event, context):
    body = json.loads(event.get("body", "{}"))
    query = body.get("query")

    docs = search_vector_db(query)
    result = run_multi_agent(f"{query} with context {docs}")

    return {"statusCode": 200, "body": json.dumps(result)}