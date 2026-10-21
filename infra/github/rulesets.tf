resource "github_repository_ruleset" "main" {
  for_each = local.coding_repos

  repository  = each.key
  name        = "protect-main"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  rules {
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true

    pull_request {
      required_approving_review_count   = 1
      required_review_thread_resolution = true
      dismiss_stale_reviews_on_push     = true
    }

    dynamic "required_status_checks" {
      for_each = var.enable_required_checks ? [1] : []

      content {
        strict_required_status_checks_policy = false

        dynamic "required_check" {
          for_each = each.value.checks

          content {
            context = required_check.value
          }
        }
      }
    }
  }
}

resource "github_repository_ruleset" "dev" {
  for_each = local.coding_repos

  repository  = each.key
  name        = "protect-dev"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/dev"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true

    pull_request {
      required_approving_review_count   = 0
      required_review_thread_resolution = false
    }

    dynamic "required_status_checks" {
      for_each = var.enable_required_checks ? [1] : []

      content {
        strict_required_status_checks_policy = false

        dynamic "required_check" {
          for_each = each.value.checks

          content {
            context = required_check.value
          }
        }
      }
    }
  }
}

resource "github_repository_ruleset" "lightweight" {
  for_each = local.lightweight_repos

  repository  = each.value
  name        = "protect-main"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true
  }
}