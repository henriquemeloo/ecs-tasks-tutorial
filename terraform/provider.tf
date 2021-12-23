provider "aws" {
  region = "us-east-1"
  profile = var.profile
  default_tags {
    tags = {
      project_ref = "https://github.com/henriquemeloo/ecs-tasks-tutorial"
    }
  }
}
