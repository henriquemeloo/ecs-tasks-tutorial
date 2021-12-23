# Create a VPC to run tasks and Airflow instance
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ecs-tasks-tutorial"
  }
}

# Create subnet in the VPC
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "ecs-tasks-tutorial"
  }
}

# Create a security group where Airflow instance will be placed
resource "aws_security_group" "allow_airflow_webserver" {
  name        = "ecs-tasks-tutorial-airflow"
  description = "Used by ecs-tasks-tutorial Airflow server"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = [ "::/0" ]
    cidr_blocks      = ["0.0.0.0/0"]
  }
}