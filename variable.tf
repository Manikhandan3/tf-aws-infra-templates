variable "region" {
  type        = string
  description = "Region to set up infrastructure"
  default     = "us-east-1"
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
  default     = 1
}


variable "vpc_cidrs" {
  description = "List of CIDR blocks for each VPC"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "pr_dest_cidr" {
  description = "destination CIDR of a public route"
  type        = string
  default     = "0.0.0.0/0"
}