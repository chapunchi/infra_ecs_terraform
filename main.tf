terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "<Add access key here>"
  secret_key = "<Add secret key here>"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
}

resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.aws_internet_gateway_tags
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = var.aws_route_table_tags
}

resource "aws_subnet" "pub_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub_subnet1_cidr_block
  availability_zone = var.pub_subnet1_availability_zone
  tags              = var.pub_subnet1_tags
}

resource "aws_subnet" "pub_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub_subnet2_cidr_block
  availability_zone = var.pub_subnet2_availability_zone
  tags              = var.pub_subnet2_tags
}

resource "aws_route_table_association" "aws_route_table_association" {
  subnet_id      = aws_subnet.pub_subnet1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_security_group" "ecs_sg" {
  name        = var.ecs_sg_name
  description = var.ecs_sg_description
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.ecs_sg_tags
}

resource "aws_security_group" "rds_sg" {
  name        = var.rds_sg_name
  description = var.rds_sg_description
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.rds_sg_tags
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = var.ecs_agent_name
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = var.ecs_agent_policy_arn
}
resource "aws_iam_instance_profile" "ecs_agent" {
  name = var.aws_iam_instance_profile_name
  role = aws_iam_role.ecs_agent.name
}

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = var.ecs_launch_config_image_id
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.ecs_sg.id]
  user_data            = var.ecs_launch_config_user_data
  instance_type        = var.ecs_launch_config_instance_type
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                 = var.failure_analysis_ecs_asg_name
  vpc_zone_identifier  = [aws_subnet.pub_subnet1.id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = var.failure_analysis_ecs_asg_desired_capacity
  min_size                  = var.failure_analysis_ecs_asg_min_size
  max_size                  = var.failure_analysis_ecs_asg_max_size
  health_check_grace_period = var.failure_analysis_ecs_asg_health_check_grace_period
  health_check_type         = var.failure_analysis_ecs_asg_health_check_type
}

resource "aws_db_subnet_group" "mysql-subnet-group" {
  name       = var.mysql-subnet-group_name
  subnet_ids = [aws_subnet.pub_subnet1.id, aws_subnet.pub_subnet2.id]
}

resource "aws_db_instance" "mysql" {
  identifier                = var.mysql_identifier
  allocated_storage         = var.mysql_allocated_storage
  backup_retention_period   = var.mysql_backup_retention_period
  backup_window             = var.mysql_backup_window
  maintenance_window        = var.mysql_maintenance_window
  multi_az                  = var.mysql_multi_az
  engine                    = var.mysql_engine
  engine_version            = var.mysql_engine_version
  instance_class            = var.mysql_instance_class
  name                      = var.mysql_name
  username                  = var.mysql_username
  password                  = var.mysql_password
  port                      = var.mysql_port
  db_subnet_group_name      = aws_db_subnet_group.mysql-subnet-group.name
  vpc_security_group_ids    = [aws_security_group.rds_sg.id, aws_security_group.ecs_sg.id]
  skip_final_snapshot       = var.mysql_skip_final_snapshot
  final_snapshot_identifier = var.mysql_final_snapshot_identifier
  publicly_accessible       = var.mysql_publicly_accessible
}

resource "aws_ecr_repository" "worker" {
  name = var.aws_ecr_repository_name
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.aws_ecs_cluster_ecs_cluster_name
}

data "template_file" "task_definition_template" {
  template = file("task_definition.json.tpl")
  vars = {
    REPOSITORY_URL = replace(aws_ecr_repository.worker.repository_url, "https://", "")
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = var.aws_ecs_task_definition_task_definition_family
  container_definitions = data.template_file.task_definition_template.rendered
}

resource "aws_ecs_service" "worker" {
  name            = var.aws_ecs_service_worker_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.aws_ecs_service_worker_desired_count
}

output "mysql_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "ecr_repository_worker_endpoint" {
  value = aws_ecr_repository.worker.repository_url
}

