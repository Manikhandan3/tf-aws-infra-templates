# Scalable & Secure AWS Web Application Infrastructure

This project provisions a scalable, secure, and highly available web application infrastructure on AWS using Terraform. It sets up a multi-AZ environment with a VPC, public and private subnets, an Application Load Balancer, an Auto Scaling Group for EC2 instances, and an RDS database, all following best practices for security and automation.

The infrastructure is designed to be modular and reusable, allowing for the creation of multiple, isolated environments (e.g., dev, staging, prod) by simply changing the input variables.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Core Features](#core-features)
  - [Networking](#networking)
  - [Compute & Scaling](#compute--scaling)
  - [Load Balancing & DNS](#load-balancing--dns)
  - [Database](#database)
  - [Storage](#storage)
  - [Security & IAM](#security--iam)
  - [Automation & CI/CD](#automation--cicd)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Deployment Instructions](#deployment-instructions)
- [Destroying the Infrastructure](#destroying-the-infrastructure)

## Architecture Overview

The architecture consists of the following key components:

- **VPC**: A logically isolated section of the AWS Cloud with a custom CIDR block.
- **Subnets**: Public and private subnets are provisioned across multiple Availability Zones (AZs) to ensure high availability.
  - **Public Subnets**: Host the Application Load Balancer and allow outbound internet access for EC2 instances via an Internet Gateway.
  - **Private Subnets**: Host the RDS database instance, isolating it from public internet access.
- **Application Load Balancer (ALB)**: Distributes incoming HTTPS traffic across the EC2 instances in the Auto Scaling Group.
- **Auto Scaling Group (ASG)**: Manages EC2 instances, automatically scaling the number of instances up or down based on CPU load. Instances are launched from a predefined Launch Template.
- **RDS Database**: A managed MySQL database instance running in the private subnets, accessible only by the EC2 instances.
- **Security**: A multi-layered security approach is used, including Security Groups, IAM Roles, KMS encryption for all data-at-rest, and secure secret management with AWS Secrets Manager.
- **DNS**: A Route 53 record points your custom domain to the ALB.

## Core Features

### Networking

- **Dynamic VPC Creation**: Creates one or more Virtual Private Clouds (VPCs) based on the `vpc_count` variable.
- **High Availability Subnetting**: Deploys public and private subnets across multiple Availability Zones for fault tolerance.
- **Internet Gateway**: Configures an Internet Gateway (IGW) for resources in public subnets to communicate with the internet.
- **Segregated Route Tables**: Sets up separate Route Tables for public and private subnets to control traffic flow.

### Compute & Scaling

- **Launch Templates**: Uses a Launch Template to define a standard configuration for EC2 instances, including AMI, instance type, and IAM profile.
- **Auto Scaling**: Deploys an Auto Scaling Group (ASG) to manage EC2 instances, ensuring the desired capacity is always running.
- **CPU-Based Scaling Policies**: Includes CloudWatch alarms that trigger scale-up and scale-down policies based on average CPU utilization, ensuring performance and cost-efficiency.
- **Instance User Data**: Bootstraps instances with user data to configure the application environment, including setting up environment variables from RDS and Secrets Manager.

### Load Balancing & DNS

- **Application Load Balancer (ALB)**: Provisions an ALB to intelligently distribute traffic to healthy EC2 instances.
- **HTTPS Listener**: Configures a secure HTTPS listener on port 443, using a specified SSL certificate from AWS Certificate Manager (ACM).
- **Robust Health Checks**: The ALB Target Group continuously monitors the health of instances on a specified path (`/healthz`).
- **Automated DNS**: Automatically creates a Route 53 'A' (Alias) record to point a custom domain to the ALB.

### Database

- **Managed RDS Instance**: Deploys a managed MySQL RDS instance, reducing operational overhead.
- **Private & Secure**: The database is placed in private subnets, accessible only from the application's security group.
- **Custom Configuration**: Utilizes a custom DB Parameter Group and a DB Subnet Group.
- **Automated Password Management**: The database password is automatically generated and securely stored.

### Storage

- **Private S3 Bucket**: Creates a private S3 bucket for application data storage.
- **Forced Encryption**: Enforces server-side encryption (SSE-KMS) on all objects using a dedicated KMS key.
- **Public Access Block**: All public access to the S3 bucket is blocked by default.
- **Cost-Optimization Lifecycle**: Includes a lifecycle rule to transition objects to STANDARD_IA storage class after 30 days.

### Security & IAM

- **Encryption at Rest**: Implements end-to-end encryption using AWS Key Management Service (KMS) for:
  - EC2 EBS Volumes
  - S3 Bucket Objects
  - RDS Database Instance
  - Secrets in AWS Secrets Manager

- **Secrets Management**: Automatically generates a random password for the RDS database and stores it securely in AWS Secrets Manager. The EC2 instances retrieve it at boot time via their IAM role.

- **Principle of Least Privilege (IAM)**: Creates a dedicated IAM role for EC2 instances with fine-grained permissions to access only the necessary services (S3, KMS, Secrets Manager).

- **Layered Security Groups**:
  - **Load Balancer SG**: Allows public HTTPS traffic (port 443) to the ALB.
  - **Application SG**: Allows traffic only from the ALB's security group to the EC2 instances on the application port.
  - **Database SG**: Allows traffic only from the Application SG to the RDS database on the MySQL port (3306).

- **SSH Key Management**: Generates a new SSH key pair, uploads the public key to AWS, and saves the private key (.pem) locally for secure instance access.

### Automation & CI/CD

- **GitHub Actions Workflow**: Includes a CI/CD pipeline (`.github/workflows/validate.yml`) that automatically runs `terraform fmt -check` and `terraform validate` on every pull request to `main`, ensuring code quality and preventing syntax errors from being merged.

## Prerequisites

- Terraform v1.3+
- AWS CLI configured with appropriate credentials
- AWS IAM User with sufficient permissions to create all the resources defined in this project
- An SSL Certificate imported into AWS Certificate Manager (ACM) in the target region
- A Hosted Zone configured in AWS Route 53 for your domain name

## Configuration

1. Clone the repository to your local machine.
2. Create a file named `terraform.tfvars` in the root of the project.
3. Populate `terraform.tfvars` with the required values. Use the example below as a template.

### terraform.tfvars.example

```hcl
# AWS Configuration
region  = "us-east-1"
profile = "default"

# VPC & Networking Configuration
vpc_name           = "webapp-vpc"
vpc_count          = 1
vpc_cidrs          = ["10.0.0.0/16"]
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
pr_dest_cidr       = "0.0.0.0/0"

# EC2 & Application Configuration
custom_ami_id    = "ami-0c55b159cbfafe1f0" # Example: Amazon Linux 2 AMI
instance_type    = "t2.micro"
application_port = 8080

# SSH Key Configuration
key_name        = "webapp-key"
key_output_path = "./keys" # Path to save the generated .pem file

# RDS Database Configuration
db_name     = "webappdb"
db_username = "admin"

# DNS & SSL Configuration
domain_name         = "example.com"
environment         = "dev" # Subdomain (e.g., dev.example.com)
route53_zone_id     = "Z0123456789ABCDEFGHIJ"
ssl_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-cert-uuid"
```

## Deployment Instructions

### 1. Initialize Terraform

This command downloads the required providers and initializes the backend.

```bash
terraform init
```

### 2. Create and Select a Workspace (Optional but Recommended)

Using workspaces helps isolate state files for different environments.

```bash
terraform workspace new dev
terraform workspace select dev
```

### 3. Plan the Infrastructure

Review the changes Terraform will make before applying them.

```bash
terraform plan -var-file="terraform.tfvars"
```

### 4. Apply the Infrastructure

This command will build and deploy all the AWS resources.

```bash
terraform apply -var-file="terraform.tfvars"
```

After a successful apply:

- The infrastructure will be running on AWS
- The SSH private key will be saved to the path specified in `key_output_path` (e.g., `./keys/webapp-key.pem`)
- The Route 53 record will be created, and your application should be accessible at `https://<environment>.<domain_name>`

## Destroying the Infrastructure

To tear down all the resources created by this project, run the following command. **Warning: This action is irreversible.**

```bash
terraform destroy -var-file="terraform.tfvars"
```
