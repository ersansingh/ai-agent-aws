# Enterprise AI Agent Platform

A production-grade, fully private AI platform built on AWS that demonstrates enterprise architecture patterns for GenAI systems including multi-agent reasoning, RAG with vector DB, zero-trust private architecture, blue/green deployments with auto rollback, CI/CD using GitHub Actions + OIDC, and multi-environment support.

## Stack
- **Language**: Python 3.10 (Lambda runtime)
- **Framework**: Custom multi-agent system using Bedrock (Claude-v2) + Titan embeddings
- **Vector DB**: Amazon OpenSearch (for semantic search)
- **Session Store**: DynamoDB
- **Secrets**: AWS Secrets Manager
- **Orchestration**: Lambda (VPC) with multi-agent Python modules
- **IaC**: Terraform ≥ 1.5
- **CI/CD**: GitHub Actions + OIDC (no AWS secrets)
- **Deployment**: AWS CodeDeploy (Blue/Green)
- **Monitoring**: CloudWatch + X-Ray
- **Package Manager**: pip (requirements.txt)

## Core Directories
- `lambda/` - Lambda function code (`agent.py`, `multi_agent.py`, `rag.py`, `embeddings.py`, `config.py`, `ingest.py`)
- `terraform/` - Terraform configuration for all environments (`main.tf`, `variables.tf`, `backend.tf`, `envs/*.tfvars`)
- `.github/workflows/` - GitHub Actions CI/CD pipeline (`deploy.yml`)
- `README.md` - Project documentation

## Commands
- **Build Lambda**: `pip install -r lambda/requirements.txt -t . && zip -r lambda.zip .`
- **Deploy**: `git push` (triggers CI/CD pipeline)
- **Run RAG**: `curl -X POST <API_URL>/agent -H "Content-Type: application/json" -d '{"query":"..."}'`
- **Ingest Documents**: `python lambda/ingest.py`
- **Terraform Init**: `cd terraform && terraform init`
- **Terraform Apply**: `cd terraform && terraform apply -var-file=envs/<env>.tfvars`
- **Check Health**: `curl -X GET <API_URL>/health`

## Architecture Patterns
- **Multi-Agent Reasoning**: Planner → Retriever → Executor → Critic workflow
- **Zero-Trust Security**: Fully private VPC with no internet access, VPC endpoints for Bedrock, DynamoDB, Secrets Manager
- **Blue/Green Deployments**: Automated rollout with CloudWatch alarm-based rollback
- **Secure CI/CD**: GitHub OIDC authentication to AWS, no AWS credentials stored
- **Environment Isolation**: Separate tfvars for dev/staging/prod, same codebase
- **Secrets Management**: All credentials via Secrets Manager, never hardcoded
- **Observability**: X-Ray tracing for Lambda, CloudWatch logs & alarms

## Important Files
- `lambda/agent.py` - Main Lambda handler
- `lambda/multi_agent.py` - Multi-agent orchestration logic
- `lambda/rag.py` - Retrieval-Augmented Generation implementation
- `lambda/embeddings.py` - Titan embeddings integration
- `lambda/config.py` - Configuration management
- `lambda/ingest.py` - Document ingestion pipeline
- `terraform/main.tf` - Core Terraform configuration
- `terraform/envs/*.tfvars` - Environment-specific variables
- `.github/workflows/deploy.yml` - CI/CD pipeline definition
- `README.md` - Comprehensive project documentation

## Don't
- Never commit `.env` files or hardcoded secrets
- Never modify production Terraform state without approval
- Never expose internal endpoints publicly
- Never disable security scans or vulnerability checks
- Never remove CloudWatch alarms or alarm thresholds
- Never bypass OIDC authentication in CI/CD
- Never use public internet access from Lambda functions

## Setup & Development
1. **Initial Setup**: Follow README section "Initial Setup (One-Time)"
2. **Create Terraform Backend**: `aws s3 mb s3://ai-agent-terraform-state` and DynamoDB table creation
3. **Setup OIDC**: Configure GitHub OIDC provider and IAM role in AWS
4. **Local Development**: Test Lambda handler locally with appropriate mocks
5. **Ingest Documents**: Run `python lambda/ingest.py` to populate vector DB
6. **Deploy**: Push code to trigger CI/CD pipeline

## Monitoring & Operations
- **CloudWatch Alarms**: Configured for Lambda errors and deployment failures
- **X-Ray Tracing**: Enabled for Lambda functions to monitor latency
- **Log Groups**: Centralized logging with retention policies
- **Rollback Strategy**: Automatic rollback triggered by CloudWatch alarms
- **Health Checks**: `/health` endpoint for API monitoring

---

This CLAUDE.md captures the essential project context for Claude Code to understand the architecture, commands, and operational patterns. It will be used to provide relevant suggestions and maintain project-specific conventions.