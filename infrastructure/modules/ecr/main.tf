resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_ecr_lifecycle_policy" "default" {
  count = var.enable_lifecycle_policy ? 1 : 0

  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged >14d"
      selection = {
        tagStatus     = "untagged"
        countType     = "sinceImagePushed"
        countUnit     = "days"
        countNumber   = 14
      }
      action = { type = "expire" }
    }]
  })
}
