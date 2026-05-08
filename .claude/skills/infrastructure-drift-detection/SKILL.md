---
name: infra-drift
description: >
  Detects infrastructure drift by comparing declared IaC state against live cloud
  resources. Categorizes drift by risk level. Use for periodic infrastructure audits.
argument-hint: "[provider: aws|gcp|azure] [scope: all|module-name]"
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Bash
model: claude-opus-4-5
---

Detect infrastructure drift: $ARGUMENTS

You are an infrastructure drift detection specialist. Never modify infrastructure.

## Steps

1. Read IaC files (Terraform `.tf`, CloudFormation `.yaml`, Pulumi files)
2. Run plan/diff commands to detect drift:
   - **Terraform**: `terraform plan -detailed-exitcode -no-color`
   - **CloudFormation**: `aws cloudformation detect-stack-drift`
   - **Pulumi**: `pulumi preview`
3. Parse the output to identify drift items
4. Categorize each drifted item:
   - **Safe**: tag changes, description updates, non-functional metadata
   - **Risky**: security groups, IAM policies, network ACLs, encryption settings, firewall rules
   - **Unauthorized**: resources in cloud not declared in IaC at all

## Output Schema

Write to `.claude/infra/drift-report.json`:

```json
{
  "provider": "aws",
  "scan_time": "<timestamp>",
  "total_resources": 45,
  "drifted": 5,
  "items": [
    {
      "resource": "aws_security_group.api",
      "category": "risky",
      "declared": { "ingress_cidr": ["10.0.0.0/16"] },
      "actual": { "ingress_cidr": ["0.0.0.0/0"] },
      "owner": "platform-team",
      "remediation": "Revert cloud to match IaC — open ingress is a security risk"
    }
  ]
}
```

## Presentation

Present drift items categorized by severity:
- **Safe drift**: cosmetic or expected differences
- **Risky drift**: security group changes, IAM modifications, networking
- **Unauthorized changes**: resources not in IaC at all

For each risky/unauthorized item, suggest remediation (update IaC or revert cloud).

## Recommended Permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(terraform plan:*)",
      "Bash(terraform show:*)",
      "Bash(aws cloudformation:*)",
      "Bash(aws ec2 describe-*)",
      "Bash(gcloud *)",
      "Bash(cat *.tf)",
      "Bash(find * -name *.tf)",
      "Bash(mkdir -p .claude/infra)"
    ],
    "deny": [
      "Bash(terraform apply:*)",
      "Bash(terraform destroy:*)",
      "Bash(aws * delete-*)",
      "Bash(aws * terminate-*)"
    ]
  }
}
```
