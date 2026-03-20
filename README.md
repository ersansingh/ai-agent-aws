# 🚀 Enterprise AI Agent Platform

A **production-grade, fully private AI platform** built on AWS.

This project demonstrates **enterprise architecture patterns** for GenAI systems including:

- 🤖 Multi-agent reasoning (Planner, Retriever, Executor, Critic)
- 🔎 RAG (Retrieval-Augmented Generation) with Vector DB
- 🔐 Zero-trust private architecture (no internet access)
- 🔁 Blue/Green deployments with auto rollback (CodeDeploy)
- ⚙️ CI/CD using GitHub Actions + OIDC (no secrets)
- 🌍 Multi-environment (dev / staging / prod)

---

# 🏗️ Architecture Overview

## Core Components

- **API Gateway** → public entry point
- **Lambda (VPC)** → multi-agent orchestration
- **Amazon Bedrock** → LLM (Claude) + embeddings (Titan)
- **OpenSearch** → vector database (semantic search)
- **DynamoDB** → session memory
- **Secrets Manager** → secure config
- **CodeDeploy** → Blue/Green + rollback
- **CloudWatch + X-Ray** → monitoring & tracing

---

# 📁 Project Structure

```
ai-agent-platform/
├ terraform/
│  ├ main.tf
│  ├ network.tf
│  ├ security.tf
│  ├ monitoring.tf
│  ├ backend.tf
│  ├ variables.tf
│  ├ outputs.tf
│  └ envs/
│     ├ dev.tfvars
│     ├ staging.tfvars
│     └ prod.tfvars
│
├ lambda/
│  ├ agent.py
│  ├ multi_agent.py
│  ├ rag.py
│  ├ embeddings.py
│  ├ config.py
│  ├ ingest.py
│  └ requirements.txt
│
├ .github/workflows/
│  └ deploy.yml
│
└ README.md
```

---

# ⚙️ Prerequisites

- AWS account
- Terraform ≥ 1.5
- Python 3.10
- GitHub repository

---

# 🔐 Initial Setup (One-Time)

## 1. Create Terraform Backend

```bash
aws s3 mb s3://ai-agent-terraform-state

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

---

## 2. Setup OIDC (GitHub → AWS)

1. Create OIDC provider in AWS
2. Create IAM role for GitHub Actions
3. Add trust policy for your repo/branch
4. Use role in CI/CD (`role-to-assume`)

---

# 🚀 Deployment

## Option 1 — CI/CD (Recommended)

```bash
git push
```

Pipeline will:

1. Build Lambda
2. Run Terraform (plan → apply)
3. Deploy new Lambda version
4. Trigger CodeDeploy (Blue/Green)
5. Perform canary rollout + rollback if needed

---

## Option 2 — Manual Deployment

```bash
cd lambda
pip install -r requirements.txt -t .
zip -r ../lambda.zip .

cd ../terraform
terraform init
terraform apply -var-file=envs/dev.tfvars
```

---

# 🔄 Multi-Environment Deployment

| Environment | Behavior |
|------------|---------|
| dev | auto deploy |
| staging | approval required |
| prod | strict approval |

Each environment uses:

- Separate naming (`-dev`, `-prod`)
- Separate tfvars
- Same code, isolated infra

---

# 🧪 Testing

```bash
curl -X POST <API_URL>/agent \
-H "Content-Type: application/json" \
-d '{"query":"Explain AI architecture"}'
```

---

# 🔎 RAG Workflow

1. Add documents
2. Generate embeddings
3. Store in OpenSearch
4. Query system

```bash
python lambda/ingest.py
```

---

# 🔁 Deployment Strategy

- Canary rollout: 10% → 100%
- Automatic rollback via CloudWatch alarms
- Zero downtime deployments

---

# 🔐 Security Features

- Fully private VPC (no internet access)
- VPC endpoints (Bedrock, DynamoDB, Secrets)
- Secrets Manager (no hardcoding)
- IAM least privilege
- OIDC authentication (no AWS keys)

---

# 📊 Monitoring

- CloudWatch logs
- CloudWatch alarms (rollback trigger)
- X-Ray tracing

---

# ⚠️ Common Issues

| Issue | Fix |
|------|-----|
| Lambda timeout | check VPC endpoints |
| RAG not working | verify OpenSearch endpoint |
| CI/CD fails | validate OIDC role |
| Terraform errors | check backend.tf |

---

# 📈 Scaling Strategy

| Layer | Scaling |
|------|--------|
| Lambda | concurrency |
| OpenSearch | sharding |
| Agents | parallel execution |

---

# 🚀 Future Enhancements

- Multi-region deployment
- Disaster recovery (DR)
- EKS-based agents
- LangGraph orchestration
- Hybrid search (vector + keyword)

---

# 🎯 Key Features Summary

- ✔ Fully private architecture
- ✔ Multi-agent AI system
- ✔ RAG with vector DB
- ✔ Blue/Green deployment
- ✔ Auto rollback
- ✔ Secure CI/CD (OIDC)
- ✔ Multi-environment support

---

# 🏁 Conclusion

This project represents a **real enterprise-grade AI platform** combining:

- Cloud-native infrastructure
- Secure DevOps practices
- Advanced AI system design

---

