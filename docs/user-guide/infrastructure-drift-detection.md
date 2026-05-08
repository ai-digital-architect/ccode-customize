# Infrastructure Drift Detection

## Purpose

The infrastructure drift detection skill compares declared Infrastructure-as-Code (IaC) state against live cloud resources to identify configuration drift. It categorizes drift by risk level and suggests remediation. The skill never modifies infrastructure.

Use this skill:
- For periodic infrastructure audits
- After manual cloud console changes to detect undeclared modifications
- Before infrastructure changes to understand the current drift state

## Prerequisites

- IaC files in the project (Terraform `.tf`, CloudFormation `.yaml`, or Pulumi files)
- Cloud CLI tools configured and authenticated (`terraform`, `aws`, `gcloud`, or `az`)
- Plan/preview commands must be runnable from the project directory
- This skill uses the `claude-opus-4-5` model for deeper analysis

## Usage

Invoke the skill with a slash command:

```
/infra-drift [provider] [scope]
```

Arguments:
- `provider` -- `aws`, `gcp`, or `azure`
- `scope` -- `all` to check all modules, or a specific module name

## Example

```
/infra-drift aws all
```

This reads all Terraform files, runs `terraform plan -detailed-exitcode`, parses the output to identify drifted resources, and categorizes each by risk level.

```
/infra-drift gcp networking
```

This checks only the networking module for drift against GCP.

## Output

The skill writes a structured report to `.claude/infra/drift-report.json` containing:

- **Provider** and **scan timestamp**
- **Total resources** scanned and **drifted count**
- **Drift items**, each with: resource name, category (safe/risky/unauthorized), declared vs. actual values, owning team, and remediation suggestion

Drift is categorized into three levels:
- **Safe drift** -- cosmetic changes like tags or descriptions
- **Risky drift** -- security groups, IAM policies, network ACLs, encryption settings
- **Unauthorized changes** -- resources in the cloud that are not declared in IaC at all

Every risky and unauthorized item includes a remediation recommendation (update IaC or revert cloud).

## Tips

- Destructive commands (`terraform apply`, `terraform destroy`, `aws delete-*`) are explicitly denied -- the skill is safe to run.
- Run after any manual cloud console changes to catch undeclared modifications.
- Add recommended permissions and denials:
  ```json
  {
    "permissions": {
      "allow": [
        "Bash(terraform plan:*)",
        "Bash(terraform show:*)",
        "Bash(aws cloudformation:*)",
        "Bash(cat *.tf)",
        "Bash(mkdir -p .claude/infra)"
      ],
      "deny": [
        "Bash(terraform apply:*)",
        "Bash(terraform destroy:*)",
        "Bash(aws * delete-*)"
      ]
    }
  }
  ```
- Review safe drift items periodically -- accumulated safe drift can mask risky changes.

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| "terraform plan" fails | Terraform not initialized or backend not configured | Run `terraform init` before invoking the skill |
| Authentication errors | Cloud CLI not authenticated | Run `aws configure`, `gcloud auth login`, or `az login` first |
| No drift detected | IaC and cloud state are in sync | This is a clean result -- no action needed |
| Unauthorized resources not detected | Resources exist in a different region or account | Ensure the CLI is configured for the correct region and account |
