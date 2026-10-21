variable "github_owner" {
  description = "GitHub organization name"
  type        = string
}

variable "enable_required_checks" {
  description = "Enable required CI status checks"
  type        = bool
  default     = false
}