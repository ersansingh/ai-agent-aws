import requests
from embeddings import generate_embedding

ENDPOINT = "https://your-opensearch-endpoint"

def search_vector_db(query):
    vector = generate_embedding(query)

    res = requests.post(
        f"{ENDPOINT}/documents/_search",
        json={
            "size": 3,
            "query": {
                "knn": {
                    "embedding": {
                        "vector": vector,
                        "k": 3
                    }
                }
            }
        }
    )

    return [h["_source"]["text"] for h in res.json()["hits"]["hits"]]