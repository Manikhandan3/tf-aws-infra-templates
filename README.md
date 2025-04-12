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

# SSL Certificate Configuration

## Importing an SSL Certificate to AWS Certificate Manager

Before deploying the infrastructure, you need to import your SSL certificate to AWS Certificate Manager. Follow these steps:

1. Prepare your SSL certificate files:
   - Certificate body (PEM-encoded)
   - Private key (PEM-encoded)
   - Certificate chain (if applicable)

2. Use the AWS CLI to import the certificate:

```bash
aws acm import-certificate \
  --certificate file://certificate.pem \
  --private-key file://private-key.pem \
  --certificate-chain file://certificate-chain.pem \
  --region  \
  --tags Key=Environment,Value= Key=Project,Value=
```

3. Note the ARN of the imported certificate in the output.

4. When deploying with Terraform, use one of the following approaches:

   a. **Provide the certificate ARN directly** (recommended for production):
   - Add the ARN to your terraform.tfvars file:
      ```
      ssl_certificate_arn = "arn:aws:acm:region:account-id:certificate/certificate-id"
      ```

   b. **Let Terraform find the certificate** (if you're sure there won't be conflicts):
   - Terraform will find the certificate based on the domain name, status, and (if configured) tags.
   - Make sure your domain name variable exactly matches the primary domain on the certificate.

## Managing Multiple Certificates

If you have multiple certificates for the same domain (perhaps for different environments):

1. Use tags when importing certificates to distinguish them:
   ```bash
   aws acm import-certificate --tags Key=Environment,Value=production Key=Application,Value=webapp
   ```

2. In your Terraform configuration, use the same tags to filter for the specific certificate.

## SSL Configuration Notes

- The load balancer is configured to serve traffic only on port 443 (HTTPS) using the imported SSL certificate.
- We use the TLS 1.3 compatible security policy (ELBSecurityPolicy-TLS13-1-2-2021-06) for enhanced security.
- Traffic from the load balancer to EC2 instances uses HTTP (port specified in `application_port` variable).
- HTTP to HTTPS redirection is not implemented in this configuration.

