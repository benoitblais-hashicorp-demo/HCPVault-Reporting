# Root namespace for reporting demo - provides isolation
resource "vault_namespace" "reporting_demo" {
  path = "reporting-demo"

  custom_metadata = merge(
    var.namespace_custom_metadata,
    {
      "type"    = "root"
      "purpose" = "reporting-demo-isolation"
    }
  )
}

# Demo namespace - simple example
resource "vault_namespace" "demo" {
  count = var.enable_demo_namespace ? 1 : 0

  namespace = vault_namespace.reporting_demo.path
  path      = "demo"

  custom_metadata = merge(
    var.namespace_custom_metadata,
    {
      "type" = "demo"
    }
  )
}

# Userpass auth backend in reporting-demo namespace
resource "vault_auth_backend" "userpass" {
  count = var.enable_userpass_auth ? 1 : 0

  namespace   = vault_namespace.reporting_demo.path_fq
  type        = "userpass"
  path        = "userpass"
  description = "Username and password authentication for administrators and operators"

  tune {
    default_lease_ttl = "1h"
    max_lease_ttl     = "8h"
    token_type        = "service"
  }
}

# Generate random passwords for userpass users
resource "random_password" "userpass_passwords" {
  for_each = var.enable_userpass_auth ? var.userpass_users : {}

  length  = var.userpass_password_length
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Create userpass users in reporting-demo namespace
resource "vault_generic_endpoint" "userpass_users" {
  for_each = var.enable_userpass_auth ? var.userpass_users : {}

  depends_on           = [vault_auth_backend.userpass, random_password.userpass_passwords]
  namespace            = vault_namespace.reporting_demo.path_fq
  path                 = "auth/userpass/users/${each.key}"
  ignore_absent_fields = true

  data_json = jsonencode({
    password = random_password.userpass_passwords[each.key].result
    policies = each.value.policies
  })
}

# AppRole auth backend in reporting-demo namespace
resource "vault_auth_backend" "approle_admin" {
  count = var.enable_approle_auth ? 1 : 0

  namespace   = vault_namespace.reporting_demo.path_fq
  type        = "approle"
  path        = "approle"
  description = "AppRole authentication for applications and automation in reporting-demo namespace"

  tune {
    default_lease_ttl = "1h"
    max_lease_ttl     = "24h"
    token_type        = "service"
  }
}

resource "vault_approle_auth_backend_role" "admin_automation" {
  count = var.enable_approle_auth ? 1 : 0

  namespace      = vault_namespace.reporting_demo.path_fq
  backend        = vault_auth_backend.approle_admin[0].path
  role_name      = "admin-automation"
  token_policies = ["admin", "default"]
  token_ttl      = 3600
  token_max_ttl  = 86400
}

# Fake roles in reporting-demo namespace for entity count
resource "vault_approle_auth_backend_role" "admin_fake" {
  count = var.enable_approle_auth && var.create_fake_roles ? var.fake_roles_count : 0

  namespace      = vault_namespace.reporting_demo.path_fq
  backend        = vault_auth_backend.approle_admin[0].path
  role_name      = "admin-fake-role-${count.index + 1}"
  token_policies = ["default"]
  token_ttl      = 600
  token_max_ttl  = 3600
}

# Top-level organizational namespaces under reporting-demo
resource "vault_namespace" "engineering" {
  namespace = vault_namespace.reporting_demo.path
  path      = "engineering"

  custom_metadata = merge(
    var.namespace_custom_metadata,
    {
      "type"       = "organization"
      "department" = "engineering"
    }
  )
}

resource "vault_namespace" "production" {
  namespace = vault_namespace.reporting_demo.path
  path      = "production"

  custom_metadata = merge(
    var.namespace_custom_metadata,
    {
      "type"        = "environment"
      "environment" = "production"
    }
  )
}

# AppRole auth backend in engineering namespace
resource "vault_auth_backend" "approle_engineering" {
  count = var.enable_approle_auth ? 1 : 0

  namespace   = vault_namespace.engineering.path_fq
  type        = "approle"
  path        = "approle"
  description = "AppRole authentication for engineering applications"

  tune {
    default_lease_ttl = "1h"
    max_lease_ttl     = "24h"
    token_type        = "service"
  }
}

resource "vault_approle_auth_backend_role" "engineering_automation" {
  count = var.enable_approle_auth ? 1 : 0

  namespace      = vault_namespace.engineering.path_fq
  backend        = vault_auth_backend.approle_engineering[0].path
  role_name      = "engineering-automation"
  token_policies = ["engineering", "default"]
  token_ttl      = 3600
  token_max_ttl  = 86400
}

# Fake roles in engineering namespace for entity count
resource "vault_approle_auth_backend_role" "engineering_fake" {
  count = var.enable_approle_auth && var.create_fake_roles ? var.fake_roles_count : 0

  namespace      = vault_namespace.engineering.path_fq
  backend        = vault_auth_backend.approle_engineering[0].path
  role_name      = "engineering-fake-role-${count.index + 1}"
  token_policies = ["default"]
  token_ttl      = 600
  token_max_ttl  = 3600
}

# AppRole auth backend in production namespace
resource "vault_auth_backend" "approle_production" {
  count = var.enable_approle_auth ? 1 : 0

  namespace   = vault_namespace.production.path_fq
  type        = "approle"
  path        = "approle"
  description = "AppRole authentication for production applications"

  tune {
    default_lease_ttl = "30m"
    max_lease_ttl     = "12h"
    token_type        = "service"
  }
}

resource "vault_approle_auth_backend_role" "production_automation" {
  count = var.enable_approle_auth ? 1 : 0

  namespace      = vault_namespace.production.path_fq
  backend        = vault_auth_backend.approle_production[0].path
  role_name      = "production-automation"
  token_policies = ["production", "default"]
  token_ttl      = 1800
  token_max_ttl  = 43200
}

# Fake roles in production namespace for entity count
resource "vault_approle_auth_backend_role" "production_fake" {
  count = var.enable_approle_auth && var.create_fake_roles ? var.fake_roles_count : 0

  namespace      = vault_namespace.production.path_fq
  backend        = vault_auth_backend.approle_production[0].path
  role_name      = "production-fake-role-${count.index + 1}"
  token_policies = ["default"]
  token_ttl      = 600
  token_max_ttl  = 3600
}

# Team namespaces under engineering
resource "vault_namespace" "teams" {
  for_each = var.teams

  namespace = vault_namespace.engineering.path
  path      = each.key

  custom_metadata = merge(
    var.namespace_custom_metadata,
    {
      "type" = "team"
      "team" = each.key
    }
  )
}

# AppRole auth backends in each team namespace
resource "vault_auth_backend" "approle_teams" {
  for_each = var.enable_approle_auth ? var.teams : []

  namespace   = vault_namespace.teams[each.key].path_fq
  type        = "approle"
  path        = "approle"
  description = "AppRole authentication for ${each.key} team applications"

  tune {
    default_lease_ttl = "1h"
    max_lease_ttl     = "24h"
    token_type        = "service"
  }
}

resource "vault_approle_auth_backend_role" "team_automation" {
  for_each = var.enable_approle_auth ? var.teams : []

  namespace      = vault_namespace.teams[each.key].path_fq
  backend        = vault_auth_backend.approle_teams[each.key].path
  role_name      = "${each.key}-automation"
  token_policies = ["${each.key}-team", "default"]
  token_ttl      = 3600
  token_max_ttl  = 86400
}

# Fake roles in team namespaces for entity count
resource "vault_approle_auth_backend_role" "team_fake" {
  for_each = var.enable_approle_auth && var.create_fake_roles ? {
    for pair in setproduct(tolist(var.teams), range(var.fake_roles_count)) :
    "${pair[0]}-fake-${pair[1] + 1}" => {
      team  = pair[0]
      index = pair[1]
    }
  } : {}

  namespace      = vault_namespace.teams[each.value.team].path_fq
  backend        = vault_auth_backend.approle_teams[each.value.team].path
  role_name      = "fake-role-${each.value.index + 1}"
  token_policies = ["default"]
  token_ttl      = 600
  token_max_ttl  = 3600
}

# Application namespaces under each team
resource "vault_namespace" "apps" {
  for_each = {
    for pair in setproduct(var.teams, var.apps) :
    "${pair[0]}-${pair[1]}" => {
      team = pair[0]
      app  = pair[1]
    }
  }

  namespace = vault_namespace.teams[each.value.team].path_fq
  path      = each.value.app

  custom_metadata = merge(
    var.namespace_custom_metadata,
    {
      "type"        = "application"
      "team"        = each.value.team
      "application" = each.value.app
    }
  )
}

# AppRole auth backends in each application namespace
resource "vault_auth_backend" "approle_apps" {
  for_each = var.enable_approle_auth ? {
    for pair in setproduct(var.teams, var.apps) :
    "${pair[0]}-${pair[1]}" => {
      team = pair[0]
      app  = pair[1]
    }
  } : {}

  namespace   = vault_namespace.apps[each.key].path_fq
  type        = "approle"
  path        = "approle"
  description = "AppRole authentication for ${each.value.app} in ${each.value.team} team"

  tune {
    default_lease_ttl = "30m"
    max_lease_ttl     = "12h"
    token_type        = "service"
  }
}

resource "vault_approle_auth_backend_role" "app_role" {
  for_each = var.enable_approle_auth ? {
    for pair in setproduct(var.teams, var.apps) :
    "${pair[0]}-${pair[1]}" => {
      team = pair[0]
      app  = pair[1]
    }
  } : {}

  namespace      = vault_namespace.apps[each.key].path_fq
  backend        = vault_auth_backend.approle_apps[each.key].path
  role_name      = "${each.value.app}-role"
  token_policies = [each.value.app, "default"]
  token_ttl      = 1800
  token_max_ttl  = 43200
}

# Fake roles in application namespaces for entity count
resource "vault_approle_auth_backend_role" "app_fake" {
  for_each = var.enable_approle_auth && var.create_fake_roles ? {
    for tuple in setproduct(tolist(var.teams), tolist(var.apps), range(var.fake_roles_count)) :
    "${tuple[0]}-${tuple[1]}-fake-${tuple[2] + 1}" => {
      team  = tuple[0]
      app   = tuple[1]
      index = tuple[2]
    }
  } : {}

  namespace      = vault_namespace.apps["${each.value.team}-${each.value.app}"].path_fq
  backend        = vault_auth_backend.approle_apps["${each.value.team}-${each.value.app}"].path
  role_name      = "fake-role-${each.value.index + 1}"
  token_policies = ["default"]
  token_ttl      = 600
  token_max_ttl  = 3600
}
