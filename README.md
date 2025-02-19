#  AWS VPC Setup with Terraform

## **Prerequisites**
- **Terraform** v1.3+
- **AWS CLI** configured with appropriate credentials
- **AWS IAM User** with permissions to manage VPC, Subnets, Internet Gateway, and Route Tables

---

## **Setup Instructions**

### ** Initialize Terraform**
```bash
terraform init
```
This downloads the AWS provider and initializes the working directory.

### ** Select or Create a Workspace**
```bash
terraform workspace new dev   
terraform workspace select dev 
```

### ** Plan the Infrastructure**
```bash
terraform plan -var-file="terraform.tfvars"
```
This shows the changes Terraform will make without applying them.

### ** Apply the Infrastructure**
```bash
terraform apply -var-file="terraform.tfvars"
```
This will create:
- **VPC(s)** with dynamic counts
- **3 Public Subnets** and **3 Private Subnets** (spread across 3 AZs)
- **Internet Gateway** attached to the VPC
- **Public & Private Route Tables** with correct associations

### ** Verify the Setup**
Login to your **AWS Console** → **VPC Dashboard** to verify that:
- VPC(s) are created
- Subnets are distributed across AZs
- Internet Gateway is attached
- Route tables are correctly configured

### ** Destroy the Infrastructure (if needed)**
To tear down the setup:
```bash
terraform destroy -var-file="terraform.tfvars"
```

---

## **Troubleshooting**

1. **Error: Provider Version Issues**
    - Ensure the AWS provider version matches `> 5.0, < 6.0`.

2. **Subnet CIDR Overlaps**
    - Verify subnet CIDRs do not overlap with the VPC CIDR.

3. **Permissions Denied**
    - Ensure the IAM policy has the required permissions for VPC, Subnets, IGW, and Route Tables.

---


