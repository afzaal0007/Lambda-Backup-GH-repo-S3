# 🛡️ GitHub Repo Backup to AWS S3 using Lambda & Terraform

This project automates GitHub repository backups by deploying a containerized AWS Lambda function that performs a `git clone --mirror` and uploads the result to S3. It uses **Terraform** to provision all necessary resources and integrates with **EventBridge** to schedule regular backups.

---

## ✅ Prerequisites

- AWS account with necessary permissions
- AWS CLI configured with an SSO profile (e.g. `afzaal-sso`)
- Terraform v1.3+
- Docker installed
- GitHub Personal Access Token (with repo read access)

---

## 🚀 Steps to Deploy

### 1️⃣ Create S3 Bucket and DynamoDB Table for Backend (Using Local State First)

Before using a remote backend, use local state to create the required S3 bucket and DynamoDB table:

```bash
cd infrastructure
terraform init
terraform apply -target=module.terraform_backend
```

This will provision:
- An S3 bucket for Terraform state
- A DynamoDB table for state locking

---

### 2️⃣ Configure Terraform Remote Backend

Update `provider.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-tf-state-bucket"
    key            = "github-backup/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
```

Re-initialize Terraform with the new backend:

```bash
terraform init -migrate-state
```

---

### 3️⃣ Create ECR Repository

Update your `terraform.tfvars` or pass CLI variables:

```hcl
ecr_repo_name = "github-backup"
```

Apply ECR module only:

```bash
terraform apply -target=module.ecr_repo
```

---

### 4️⃣ Build and Push Lambda Docker Image to ECR

From the `lambda/` directory:

```bash
make build
make push
```

Or manually:

```bash
docker build -t github-backup .
docker tag github-backup:latest <your_ecr_repo_uri>
docker push <your_ecr_repo_uri>
```

Update the `lambda_image_uri` in `terraform.tfvars`.

---

### 5️⃣ Deploy Lambda Function and EventBridge Rule

Ensure values are set for:
- `lambda_image_uri`
- `github_repo_url`
- `github_token`

Apply:

```bash
terraform apply
```

---

### 6️⃣ Verify Backup Workflow

- Lambda function appears in the AWS Console
- EventBridge rule is created and scheduled
- Backups appear in your S3 bucket

---

### 7️⃣ Automate Image Builds and Deployment with GitHub Actions (Optional)

Use `.github/workflows/deploy.yml` to:
- Build and push Docker image to ECR
- Optionally trigger redeploy or Terraform plan/apply

---

## 📆 Project Structure

```text
.
├── infrastructure/
│   ├── main.tf
│   ├── variables.tf
│   ├── provider.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── terraform_backend/
│       ├── s3/
│       ├── ecr/
│       ├── iam/
│       ├── lambda/
│       └── eventbridge/
├── lambda/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── Makefile
└── .github/
    └── workflows/
        └── deploy.yml
```

---

## 🔐 Example Terraform Variables (`terraform.tfvars`)

```hcl
aws_region           = "eu-west-1"
s3_bucket_name       = "my-github-backups"
ecr_repo_name        = "github-backup"
lambda_function_name = "github-backup-lambda"
lambda_image_uri     = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/github-backup:latest"
github_token         = "ghp_XXXXXXXXXXXX"
github_repo_url      = "https://github.com/your-org/your-repo.git"
schedule_expression  = "cron(0 2 * * ? *)"
```

---

## ✅ Done!

You now have an automated, scalable GitHub backup system running in AWS. 🎉
