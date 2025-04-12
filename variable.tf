variable "region" {
  type        = string
  description = "Region to set up infrastructure"
}

variable "profile" {
  type        = string
  description = "AWS profile name"
}

variable "vpc_name" {
  type        = string
  description = "AWS VPC name"
}

variable "vpc_count" {
  type        = number
  description = "AWS VPC to be created"
}


variable "vpc_cidrs" {
  description = "List of CIDR blocks for each VPC"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
}

variable "pr_dest_cidr" {
  description = "destination CIDR of a public route"
  type        = string
}

variable "custom_ami_id" {
  type        = string
  description = "Custom AMI ID for EC2 instances"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  type        = string
  description = "SSH Key pair name for EC2 instance access"
}

variable "application_port" {
  type        = number
  description = "Port on which the application runs"
}

variable "key_output_path" {
  type        = string
  description = "Path where the generated private key will be saved"
  default     = "."
}

variable "db_engine" {
  type        = string
  description = "Database engine type"
  default     = "mysql"
}

variable "db_engine_version" {
  type        = string
  description = "Database engine version"
  default     = "8.0"
}

variable "db_dialect" {
  type        = string
  description = "Database dialect"
  default     = "mysql"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Database username"
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for the domain"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the application"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "min_capacity_asg" {
  type        = number
  description = "minimum capacity of auto scaling group"
  default     = 3
}

variable "max_capacity_asg" {
  type        = number
  description = "maximum capacity of auto scaling group"
  default     = 5
}

variable "des_capacity_asg" {
  type        = number
  description = "desired capacity of auto scaling group"
  default     = 3
}

variable "health_check_type" {
  type        = string
  description = "Auto scaling group health check type"
  default     = "EC2"
}

variable "evaluation_period" {
  type        = number
  description = "evaluation period for alarm"
  default     = 1
}

variable "period" {
  type        = number
  description = "time period for alarm"
  default     = 60
}

variable "scale_up_threshold" {
  type        = number
  description = "scale up threshold"
  default     = 6.85
}

variable "scale_down_threshold" {
  type        = number
  description = "scale down threshold"
  default     = 6.25
}

variable "health_check_path" {
  type        = string
  description = "health check path for load balancer"
  default     = "/healthz"
}

variable "healthcheck_interval" {
  type        = number
  description = "health check interval"
  default     = 30
}

variable "healthy_threshold" {
  type        = number
  description = "healthy threshold for load balancer"
  default     = 3
}

variable "unhealthy_threshold" {
  type        = number
  description = "unhealthy threshold for load balancer"
  default     = 3
}

variable "healthcheck_timeout" {
  type        = number
  description = "health check timeout"
  default     = 5
}

variable "ssl_certificate_arn" {
  type        = string
  description = "ARN of the SSL certificate in ACM to use with the load balancer"
}



