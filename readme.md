# Terraform AWS Infrastructure

This Terraform repository provisions AWS infrastructure including VPC networking, S3 storage, RDS database clusters, and AWS Secrets Manager for secure credential management.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Resources Created](#resources-created)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [File Structure](#file-structure)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This Terraform configuration creates a complete AWS infrastructure setup including:

- **Networking**: VPC with public and private subnets, Internet Gateway, NAT Gateway
- **Storage**: S3 bucket with versioning and public access blocking
- **Database**: RDS cluster snapshot creation and restoration
- **Security**: AWS Secrets Manager for database credentials

## 📦 Prerequisites

Before using this Terraform configuration, ensure you have:

1. **Terraform installed** (version 1.0 or later)
   - Download from [terraform.io/downloads](https://www.terraform.io/downloads)
   - Or install via package manager:
     ```bash
     # Using Chocolatey (Windows)
     choco install terraform
     
     # Using winget (Windows)
     winget install HashiCorp.Terraform
     ```

2. **AWS CLI configured** with appropriate credentials
   ```bash
   aws configure
   ```
   - Access Key ID
   - Secret Access Key
   - Default region (e.g., `us-east-1`)
   - Output format (e.g., `json`)

3. **AWS Account** with permissions to create:
   - VPC and networking resources
   - S3 buckets
   - RDS clusters and snapshots
   - Secrets Manager secrets
   - NAT Gateways and Elastic IPs

4. **Existing RDS Cluster** (for snapshot creation)
   - The configuration references an existing cluster: `new-teadifyz-db`
   - Ensure this cluster exists or update the identifier in `rds-transer.tf`

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AWS VPC (10.0.0.0/16)                 │
│                                                          │
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │  Public Subnet   │      │  Private Subnet  │        │
│  │  (10.0.1.0/24)   │      │  (10.0.2.0/24)   │        │
│  │                  │      │                  │        │
│  │  ┌────────────┐  │      │  ┌────────────┐  │        │
│  │  │ NAT Gateway│  │      │  │ RDS Cluster│  │        │
│  │  └────────────┘  │      │  └────────────┘  │        │
│  └──────────────────┘      └──────────────────┘        │
│           │                        │                    │
│           └────────┬───────────────┘                    │
│                    │                                     │
│            ┌───────▼───────┐                            │
│            │ Internet GW   │                            │
│            └───────────────┘                            │
└─────────────────────────────────────────────────────────┘

┌──────────────────┐      ┌──────────────────┐
│   S3 Bucket      │      │ Secrets Manager  │
│  (with versioning│      │  (DB Credentials)│
│  & access block) │      │                  │
└──────────────────┘      └──────────────────┘
```

## 📚 Resources Created

### 1. Networking Infrastructure (`sg.tf`)

- **VPC**: Main VPC with CIDR `10.0.0.0/16`
  - DNS hostnames and DNS support enabled
- **Internet Gateway**: For public internet access
- **Public Subnet**: `10.0.1.0/24` in `us-east-1a`
  - Auto-assigns public IP addresses
- **Private Subnet**: `10.0.2.0/24` in `us-east-1b`
- **NAT Gateway**: Allows private subnet resources to access the internet
  - Uses Elastic IP for static public IP
- **Route Tables**: Separate routing for public and private subnets

### 2. S3 Storage (`s3.tf`)

- **S3 Bucket**: `s3-bucket-terraform-example`
  - **Public Access Block**: All public access blocked (security best practice)
  - **Versioning**: Enabled to maintain object version history
  - **Tags**: Environment and Name tags for resource management

### 3. Database Management (`rds-transer.tf`)

- **RDS Cluster Snapshot**: Creates a snapshot of existing cluster `new-teadifyz-db`
  - Snapshot identifier: `resourcetestsnapshot1234`
- **RDS Cluster Restore**: Restores a new cluster from the snapshot
  - Cluster identifier: `wow-db`
  - Engine: PostgreSQL 17.6
  - Database name: `restored_db`
  - Credentials retrieved from AWS Secrets Manager
  - Storage encryption enabled

**⚠️ Important Notes:**
- The RDS configuration references hardcoded values that need to be updated:
  - `vpc_security_group_ids`: Update with your security group ID
  - `db_subnet_group_name`: Update with your DB subnet group name
- Ensure the source cluster `new-teadifyz-db` exists before running

### 4. Secrets Management (`secretmanger.tf`)

- **Secrets Manager Secret**: Stores database credentials securely
  - Secret name: `databse-password`
  - Stores username and password as JSON
  - Used by RDS cluster for authentication

## 🚀 Installation

1. **Clone the repository** (if applicable):
   ```bash
   git clone <repository-url>
   cd terraform-awsbedrock
   ```

2. **Configure AWS credentials**:
   ```bash
   aws configure
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```
   This downloads the required AWS provider plugin.

4. **Review the configuration**:
   ```bash
   terraform plan
   ```

## ⚙️ Configuration

### Required Variables

The configuration requires the following variables defined in `variables.tf`:

- `db_username`: Database master username (sensitive)
- `db_password`: Database master password (sensitive)

### Variable Values

Create or update `terraform.tfvars` with your values:

```hcl
db_username = "your-db-username"
db_password = "your-secure-password"
```

**⚠️ Security Warning**: Never commit `terraform.tfvars` to version control if it contains sensitive data. Add it to `.gitignore`.

### Customization

Before applying, update these values in `rds-transer.tf`:

```hcl
# Line 25: Update with your security group ID
vpc_security_group_ids = ["sg-0123456789abcdef"]

# Line 26: Update with your DB subnet group name
db_subnet_group_name = "my-db-subnet-group"
```

Also, ensure the source RDS cluster identifier matches your existing cluster:

```hcl
# Line 2: Update if your cluster has a different name
db_cluster_identifier = "new-teadifyz-db"
```

## 💻 Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Plan the Deployment

Review what will be created:

```bash
terraform plan
```

### 3. Apply the Configuration

Create all resources:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 4. Verify Resources

Check that resources were created:

```bash
# List S3 buckets
aws s3 ls

# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=main"

# Check Secrets Manager
aws secretsmanager list-secrets
```

### 5. Destroy Resources (when done)

Remove all created resources:

```bash
terraform destroy
```

**⚠️ Warning**: This will delete all resources including the S3 bucket and its contents, RDS clusters, and secrets.

## 📁 File Structure

```
terraform-awsbedrock/
│
├── provider.tf              # AWS provider configuration
├── variables.tf             # Variable definitions
├── terraform.tfvars        # Variable values (DO NOT COMMIT)
├── sg.tf                   # VPC and networking resources
├── s3.tf                   # S3 bucket configuration
├── secretmanger.tf         # AWS Secrets Manager resources
├── rds-transer.tf          # RDS snapshot and restore
└── readme.md               # This file
```

### File Descriptions

- **`provider.tf`**: Configures the AWS provider (version 6.24.0) and sets the default region to `us-east-1`
- **`variables.tf`**: Defines input variables for database credentials
- **`terraform.tfvars`**: Contains actual variable values (should be in `.gitignore`)
- **`sg.tf`**: Creates complete VPC networking infrastructure
- **`s3.tf`**: Provisions S3 bucket with security and versioning
- **`secretmanger.tf`**: Manages database credentials in AWS Secrets Manager
- **`rds-transer.tf`**: Handles RDS cluster snapshots and restoration

## 🔒 Security Considerations

### 1. Sensitive Data Protection

- **Never commit `terraform.tfvars`** to version control
- Add to `.gitignore`:
  ```
  terraform.tfvars
  *.tfvars
  .terraform/
  .terraform.lock.hcl
  terraform.tfstate
  terraform.tfstate.backup
  ```

### 2. S3 Bucket Security

- Public access is blocked by default (best practice)
- Versioning is enabled for data recovery
- Consider adding encryption at rest

### 3. Secrets Manager

- Database credentials are stored securely in AWS Secrets Manager
- Secrets are encrypted at rest by AWS
- Access is controlled via IAM policies

### 4. Network Security

- Private subnet isolates database resources
- NAT Gateway allows outbound internet access without inbound exposure
- Consider adding security groups for additional network-level protection

### 5. RDS Security

- Storage encryption is enabled
- Credentials are managed via Secrets Manager
- Ensure security groups restrict access appropriately

## 🐛 Troubleshooting

### Issue: Terraform command not found

**Solution**: Install Terraform and ensure it's in your PATH.

```bash
# Verify installation
terraform version
```

### Issue: AWS credentials not configured

**Error**: `Error: No valid credential sources found`

**Solution**: Configure AWS credentials:

```bash
aws configure
```

Or set environment variables:
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Issue: S3 bucket name already exists

**Error**: `Error creating S3 bucket: BucketAlreadyExists`

**Solution**: S3 bucket names must be globally unique. Update the bucket name in `s3.tf`:

```hcl
bucket = "s3-bucket-terraform-example-unique-name"
```

### Issue: RDS cluster not found

**Error**: `Error: DBClusterNotFound`

**Solution**: 
1. Ensure the source cluster `new-teadifyz-db` exists
2. Update the cluster identifier in `rds-transer.tf` to match your existing cluster
3. Verify you have permissions to create snapshots

### Issue: Invalid security group or subnet group

**Error**: `Error: InvalidParameterValue`

**Solution**: Update the hardcoded values in `rds-transer.tf`:
- Use `terraform output` or AWS Console to find correct security group IDs
- Create or identify the correct DB subnet group name

### Issue: NAT Gateway costs

**Note**: NAT Gateways incur hourly charges (~$0.045/hour) plus data transfer costs. Consider this in your AWS budget.

## 📝 Additional Notes

### Cost Considerations

- **NAT Gateway**: ~$32/month + data transfer costs
- **RDS Cluster**: Varies by instance type and storage
- **S3**: Pay for storage and requests
- **Secrets Manager**: $0.40/month per secret

### Best Practices

1. **Use Terraform Workspaces** for environment separation (dev/staging/prod)
2. **Enable S3 bucket encryption** for additional security
3. **Use Terraform Cloud/Enterprise** for state management in teams
4. **Tag all resources** for cost tracking and organization
5. **Review `terraform plan`** output before applying
6. **Backup Terraform state** regularly

### Next Steps

Consider adding:
- CloudWatch monitoring and alarms
- S3 bucket encryption configuration
- Additional security groups for fine-grained access control
- RDS automated backups configuration
- Multi-AZ deployment for high availability

## 📞 Support

For issues or questions:
1. Check the [Terraform AWS Provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
2. Review AWS service documentation
3. Check Terraform state: `terraform show`

## 📄 License

[Specify your license here]

---

**Last Updated**: 2024

