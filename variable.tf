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
  default     = 8080
}