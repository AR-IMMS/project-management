provider "github" {
  owner = var.github_owner
}

locals {
  coding_repos = {
    core-backend = {
      checks = ["ci"]
    }

    telemetry-agent = {
      checks = ["ci"]
    }

    ar-imms-frontend = {
      checks = ["ci"]
    }
  }

  lightweight_repos = toset([
    "project-management",
    ".github",
  ])
}