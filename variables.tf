variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Project name, used as a prefix for resources"
  type        = string
  default     = "ops-demo"
}

variable "environment" {
  description = "Environment name (dev, qa, uat, prd)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to reach the web port"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alarm_email" {
  description = "Email address subscribed to the alerts SNS topic"
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "Average CPU % that triggers the alarm"
  type        = number
  default     = 80
}
