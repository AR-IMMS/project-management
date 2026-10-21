# GitHub Repository Rulesets

Manage GitHub branch protection rules using Terraform.

## Overview

This configuration manages repository-level rulesets for the AR-IMMS GitHub Organization.

| Repository           | Protected branches | Policy      |
| -------------------- | ------------------ | ----------- |
| `core-backend`       | `main`, `dev`      | Coding      |
| `telemetry-agent`    | `main`, `dev`      | Coding      |
| `project-management` | `main`             | Lightweight |
| `.github`            | `main`             | Lightweight |

### Branch policies

| Rule                    | Coding `main` | Coding `dev` | Lightweight `main` |
| ----------------------- | ------------- | ------------ | ------------------ |
| Require PR              | Yes           | Yes          | No                 |
| Required approvals      | 1             | 0            | 0                  |
| Resolve conversations   | Yes           | No           | No                 |
| Dismiss stale approvals | Yes           | No           | No                 |
| Required CI             | Optional      | Optional     | No                 |
| Linear history          | Yes           | No           | No                 |
| Prevent force push      | Yes           | Yes          | Yes                |
| Prevent deletion        | Yes           | Yes          | Yes                |

CI requirements are controlled by `enable_required_checks`.

## Prerequisites

- Terraform installed
- GitHub CLI (`gh`) installed
- GitHub account with sufficient administrative permissions on the target repositories
- Public repositories on GitHub Free

## Setup

### 1. Authenticate

```bash
gh auth login
gh auth status
```

Export a token with sufficient repository administration permissions:

```bash
export GITHUB_TOKEN="$(gh auth token)"
```

The token must have permission to manage repository rulesets. A fine-grained token generally requires repository Rules administration (write) permission.

Do not commit tokens to Git.

### 2. Configure variables

Copy the example configuration:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
github_owner = "YOUR_ORG"
enable_required_checks = false
```

Keep CI checks disabled until the required checks exist and work correctly in both coding repositories.

### 3. Initialize Terraform

From `infra/github`:

```bash
terraform init
terraform fmt -check
terraform validate
```

Commit `.terraform.lock.hcl` after initialization.

### 4. Preview changes

```bash
terraform plan
```

Review the planned changes before applying.

If matching rulesets already exist on GitHub, import them into Terraform state rather than creating duplicates.

### 5. Apply

```bash
terraform apply
```

Confirm the proposed changes.

Verify the resulting rulesets in:

GitHub Repository → Settings → Rules → Rulesets

## Daily operations

### Update rules

1. Modify `rulesets.tf` or `main.tf`.
2. Run `terraform fmt`.
3. Run `terraform validate`.
4. Run `terraform plan`.
5. Review the proposed changes.
6. Run `terraform apply`.

Always review destructive changes before applying.

### Add a coding repository

Update `local.coding_repos` in `main.tf`:

```hcl
coding_repos = {
  core-backend = {
    checks = ["ci"]
  }

  telemetry-agent = {
    checks = ["ci"]
  }

  ai-backend = {
    checks = ["ci"]
  }
}
```

Ensure the new repository and its `main` and `dev` branches exist.

Run:

```bash
terraform plan
terraform apply
```

### Enable required CI checks

First verify that the required status check named `ci` runs successfully on PRs targeting both `main` and `dev`.

Update:

```hcl
enable_required_checks = true
```

Then run:

```bash
terraform plan
terraform apply
```

**Warning:** Incorrect or missing status check names can block PR merges.

The current configuration enables required checks for all coding repositories together.

## Branch workflow

### Feature development

```text
feat/* or bug/*
       |
       | Pull Request + CI
       v
      dev
       |
       | Release PR + CI + Approval
       v
      main
```

- Create feature and bugfix branches from `dev`.
- Open PRs targeting `dev`.
- Merge only after required checks pass.
- Release to `main` through a reviewed PR.
- Use a merge method compatible with the branch ruleset.

With linear history enabled on `main`, merge commits are not permitted there. Use squash or rebase merging and maintain an explicit branch synchronization procedure.

## Terraform state

Terraform state tracks the resources managed by this configuration.

- Never commit `terraform.tfstate` or backup state files.
- Never commit credentials or secrets.
- Keep `.terraform.lock.hcl` under version control.
- Do not run concurrent Terraform applies.
- Do not delete the state file casually.
- Back up local state securely.

**Current approach:** A single designated maintainer manages the local Terraform state.

If multiple maintainers or CI automation are introduced, migrate to a shared remote backend with state locking.

## Troubleshooting

**403 Forbidden**

Check token permissions, repository administration access, and GitHub plan limitations.

**Ruleset already exists**

Import the existing ruleset into Terraform state. Do not create a duplicate.

**Required check remains pending**

Verify the exact check name, workflow triggers, and whether the workflow runs for the target branch.

**PR cannot merge**

Check approvals, unresolved review conversations, required checks, and merge method restrictions.

**Unexpected changes in `terraform plan`**

Stop and inspect Terraform state and GitHub configuration before applying. Avoid making simultaneous manual UI and Terraform changes.

## References

- [Terraform GitHub Provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [GitHub Repository Rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
