/**************************************
*
* Terraform variables definition
*
***************************************/

variable "aws_region" {
  type = string
  default = "us-west-2"
  description = "AWS region"
}

variable "app_name" {
  type = string
  default = "my-ecs-app"
  description = "Application name"
}

variable "app_environment" {
  type = string
  default = "Dev"
  description = "Application environment"
}

variable "aws_key_pair_name" {
  type = string
  default = ""
  description = "AWS key pair name"
}

variable "admin_sources_cidr" {
  type = list(string)
  default = ["10.20.0.0/24"]
  description = "List of IPv4 CIDR blocks from which to allow admin access"
}

variable "app_sources_cidr" {
  type = list(string)
  default = ["10.20.100.0/24"]
  description = "List of IPv4 CIDR blocks from which to allow application access"
}

variable "cluster_runner_type" {
  type = string
  description = "EC2 instance type of ECS Cluster Runner"
  default = "t3.medium"
}

//cluster with 2 instances by default

variable "cluster_runner_count" {
  type = string
  description = "Number of EC2 instances for ECS Cluster Runner" 
  default = "2"
}
variable "separator" {
  type = string
  description = "Separator character" 
  default = "\",\""
}

variable "image_docker_name" {
  type = string
  description = "Docker image name" 
  default = "my-nginx-ecs"
}

variable "nginx_app_name" {
  type = string
  description = "Name of Application Container"
  default = "mynginx"
}

// by default is a image with nginx + phyton static web page
variable "nginx_app_image" {
  type = string
  value = "704246131615.dkr.ecr.us-west-2.amazonaws.com/my-nginx-ecs:latest" // eliminar 
  default = "nginx:alpine"
  description = "Docker image to run in the ECS cluster"
}

variable "nginx_app_port" {
  description = "Port exposed by the Docker image to redirect traffic to"
  default = 80
}

variable "nginx_app_count" {
  description = "Number of Docker containers to run"
  default = 2
}

variable "nginx_fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default = "1024"
}

variable "nginx_fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default = "2048"
}
