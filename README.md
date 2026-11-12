# aws-terraform-starter

[![Terraform validate](https://github.com/kirandrk712/aws-terraform-starter/actions/workflows/validate.yml/badge.svg)](https://github.com/kirandrk712/aws-terraform-starter/actions/workflows/validate.yml)

A small, production-minded Terraform baseline for AWS: network, a hardened EC2 instance, an encrypted S3 bucket and CloudWatch alerting.

## What it builds

| Area | Resources |
|------|-----------|
| Network | VPC, public subnet, internet gateway, route table, security group (HTTP only) |
| Compute | EC2 (Amazon Linux 2023) running nginx, IMDSv2 enforced, encrypted gp3 root volume |
| Access | IAM role with SSM + CloudWatch agent policies - **no SSH keys or port 22** |
| Storage | S3 bucket with versioning, SSE, public access block and lifecycle rule |
| Monitoring | SNS topic + email subscription, CloudWatch alarms for high CPU and failed status checks |

## Design choices

- **SSM Session Manager instead of SSH** - smaller attack surface, no key management.
- **IMDSv2 required** - mitigates SSRF-based credential theft.
- **Everything tagged** via provider `default_tags`.
- **Variables for everything environment-specific**, so the same code serves dev/qa/prd.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # set alarm_email
terraform init
terraform fmt -check && terraform validate
terraform plan -out tfplan
terraform apply tfplan

# connect without SSH
$(terraform output -raw ssm_connect_command)

terraform destroy
```

> Confirm the SNS subscription email after `apply`, otherwise alarms won't be delivered.

## Cost

Runs on a `t3.micro` and small S3 usage. Destroy it when you're done experimenting.

## When things go wrong

See [`SCENARIOS.md`](SCENARIOS.md): CPU alarm, status-check failure, "Terraform wants to replace my instance", drift, and S3 growth - with the commands I'd run.

## Next steps

- Move state to an S3 backend with DynamoDB locking
- Split into modules (network, compute, monitoring)
- Add an ALB and Auto Scaling group
