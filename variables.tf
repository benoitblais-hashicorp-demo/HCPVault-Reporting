variable "enable_demo_namespace" {
  type        = bool
  description = "Enable the creation of a demo namespace."
  default     = true
}

variable "enable_approle_auth" {
  type        = bool
  description = "Enable the AppRole authentication method in all namespaces."
  default     = true
}

variable "create_fake_roles" {
  type        = bool
  description = "Create fake AppRole roles for entity count testing and reporting."
  default     = true
}

variable "fake_roles_count" {
  type        = number
  description = "Number of fake roles to create in each AppRole auth backend."
  default     = 1

  validation {
    condition     = var.fake_roles_count >= 1 && var.fake_roles_count <= 20
    error_message = "The fake_roles_count must be between 1 and 20."
  }
}

variable "enable_userpass_auth" {
  type        = bool
  description = "Enable the userpass authentication method in the admin namespace."
  default     = true
}

variable "namespace_custom_metadata" {
  type        = map(string)
  description = "Custom metadata describing namespaces. Requires Vault version 1.12+."
  default = {
    "managed_by" = "terraform"
    "purpose"    = "organizational_structure"
  }
}

variable "teams" {
  type        = set(string)
  description = "Set of team names to create as child namespaces under the engineering namespace."
  default = [
    "platform",
    "security",
    "data",
  ]
}

variable "apps" {
  type        = set(string)
  description = "Set of application names to create as child namespaces under each team namespace."
  default = [
    "app-frontend",
    "app-backend",
    "app-api",
  ]
}

variable "userpass_users" {
  type = map(object({
    password = string
    policies = list(string)
  }))
  description = "Map of userpass users with their passwords and policies."
  sensitive   = true
  default = {
    "admin" = {
      password = "admin-password-changeme"
      policies = ["admin", "default"]
    }
    "engineer" = {
      password = "engineer-password-changeme"
      policies = ["engineering", "default"]
    }
    "operator" = {
      password = "operator-password-changeme"
      policies = ["operator", "default"]
    }
  }
}
