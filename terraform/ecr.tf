# Create an ECR repository to store crawlers images
resource "aws_ecr_repository" "ecr_repo" {
  name = "ecs-tasks-tutorial"
  tags = {
    project = "crawlers"
  }
}
