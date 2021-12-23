# Create an IAM role for Airflow server to assume
resource "aws_iam_role" "airflow_server" {
  name                 = "ecs-tasks-tutorial-airflow_server"
  description          = "ecs-tasks-tutorial IAM role for Airflow server"
  max_session_duration = 3600
  assume_role_policy   = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  inline_policy {
    name   = "ecs-tasks-tutorial-airflow_server"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecs:DescribeTasks"
          ]
          Resource = [
            "arn:aws:ecs:${local.region}:${local.account_id}:task/ecs-tasks-tutorial/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "ecs:RunTask"
          ]
          Condition = {
            ArnEquals = {
              "ecs:cluster": aws_ecs_cluster.ecs_cluster.arn
            }
          }
          Resource = [
            aws_ecs_task_definition.ecs_task.arn
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "logs:GetLogEvents"
          ]
          Resource = [
            "${aws_cloudwatch_log_group.ecs_tasks_log_group.arn}:*"
          ]
        }
      ]
    })
  }
}
resource "aws_iam_instance_profile" "airflow_server" {
  name = aws_iam_role.airflow_server.name
  role = aws_iam_role.airflow_server.name
}


data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
# Create Airflow server instance
resource "aws_instance" "airflow_server" {
  subnet_id               = aws_subnet.main.id
  vpc_security_group_ids  = [aws_security_group.allow_airflow_webserver.id]
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = "t3a.large"
  key_name                = var.ec2_key_name
  iam_instance_profile    = aws_iam_instance_profile.airflow_server.id
  associate_public_ip_address = true
  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
    tags = {
      "Name"    = "ecs-tasks-tutorial-airflow_server"
    }
  }
  tags = {
    "Name"    = "ecs-tasks-tutorial-airflow_server"
  }
  lifecycle {
    ignore_changes = [
      instance_state,
      instance_type
    ]
  }
}