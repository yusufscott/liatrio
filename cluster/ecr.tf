resource "aws_ecr_repository" "liatrio_app" {
  name                 = "liatrio.app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}