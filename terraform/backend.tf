terraform {
  backend "s3" {
    bucket         = "ai-agent-terraform-state"   # 🔁 change to your bucket
    key            = "ai-agent/${terraform.workspace}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}