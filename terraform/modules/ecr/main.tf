# ------------------------
# modules/ecr/main.tf
# ------------------------
resource "aws_ecr_repository" "this" {
  name                 = var.repo_name
  force_delete         = true
  image_tag_mutability = "MUTABLE"
}