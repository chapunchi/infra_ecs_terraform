variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "enable_dns_support" {
  default = true
}

variable "enable_dns_hostnames" {
  default = true
}

variable "aws_internet_gateway_tags" {
  default = {
    Name = "igw1"
  }
}

variable "aws_route_table_tags" {
  default = {
    Name = "public-rt"
  }
}

variable "pub_subnet1_cidr_block" {
  default = "10.0.0.0/16"
}

variable "pub_subnet1_availability_zone" {
  default = "us-east-1a"
}

variable "pub_subnet1_tags" {
  default = {
    Name = "pub_subnet1"
  }
}

variable "pub_subnet2_cidr_block" {
  default = "10.0.2.0/24"
}

variable "pub_subnet2_availability_zone" {
  default = "us-east-1b"
}

variable "pub_subnet2_tags" {
  default = {
    Name = "pub_subnet2"
  }
}

variable "ecs_sg_name" {
  default = "ecs_sg"
}

variable "ecs_sg_description" {
  default = "Allow Web inbound traffic to ECS cluster"
}

variable "ecs_sg_tags" {
  default = {
    Name = "ecs_sg"
  }
}

variable "rds_sg_name" {
  default = "rds_sg"
}

variable "rds_sg_description" {
  default = "Allow Web inbound traffic to RDS cluster"
}

variable "rds_sg_tags" {
  default = {
    Name = "rds_sg"
  }
}

variable "ecs_agent_name" {
  default = "ecs-agent"
}

variable "ecs_agent_policy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

variable "aws_iam_instance_profile_name" {
  default = "ecs-agent"
}

variable "ecs_launch_config_image_id" {
  default = "ami-032930428bf1abbff"
}

variable "ecs_launch_config_user_data" {
  default = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
}

variable "ecs_launch_config_instance_type" {
  default = "t2.micro"
}

variable "failure_analysis_ecs_asg_name" {
  default = "asg"
}

variable "failure_analysis_ecs_asg_desired_capacity" {
  default = 2
}

variable "failure_analysis_ecs_asg_min_size" {
  default = 1
}

variable "failure_analysis_ecs_asg_max_size" {
  default = 10
}

variable "failure_analysis_ecs_asg_health_check_grace_period" {
  default = 300
}

variable "failure_analysis_ecs_asg_health_check_type" {
  default = "EC2"
}

variable "mysql-subnet-group_name" {
  default = "mysql-subnet-group"
}

variable "mysql_identifier" {
  default = "mysql"
}

variable "mysql_allocated_storage" {
  default = 5
}

variable "mysql_backup_retention_period" {
  default = 2
}

variable "mysql_backup_window" {
  default = "01:00-01:30"
}

variable "mysql_maintenance_window" {
  default = "sun:03:00-sun:03:30"
}

variable "mysql_multi_az" {
  default = true
}

variable "mysql_engine" {
  default = "mysql"
}

variable "mysql_engine_version" {
  default = "5.7"
}

variable "mysql_instance_class" {
  default = "db.t2.micro"
}

variable "mysql_name" {
  default = "worker_db"
}

variable "mysql_username" {
  default = "worker"
}

variable "mysql_password" {
  default = "5v8&agEwXA%h"
}

variable "mysql_port" {
  default = "3306"
}

variable "mysql_skip_final_snapshot" {
  default = true
}

variable "mysql_final_snapshot_identifier" {
  default = "worker-final"
}

variable "mysql_publicly_accessible" {
  default = true
}

variable "aws_ecr_repository_name" {
  default = "worker"
}

variable "aws_ecs_cluster_ecs_cluster_name" {
  default = "my-cluster"
}

variable "aws_ecs_task_definition_task_definition_family" {
  default = "worker"
}

variable "aws_ecs_service_worker_name" {
  default = "worker"
}

variable "aws_ecs_service_worker_desired_count" {
  default = 2
}


