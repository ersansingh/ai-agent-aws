from embeddings import generate_embedding
import requests

docs = ["AI architecture", "AWS best practices"]

for d in docs:
    vec = generate_embedding(d)
    requests.post("https://your-endpoint/documents/_doc",
                  json={"text": d, "embedding": vec})