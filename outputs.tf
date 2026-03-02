output "reporting_demo_namespace" {
  description = "Root reporting-demo namespace details."
  value = {
    id      = vault_namespace.reporting_demo.namespace_id
    path    = vault_namespace.reporting_demo.path
    path_fq = vault_namespace.reporting_demo.path_fq
  }
}

output "demo_namespace" {
  description = "Demo namespace details."
  value = var.enable_demo_namespace ? {
    id      = vault_namespace.demo[0].namespace_id
    path    = vault_namespace.demo[0].path
    path_fq = vault_namespace.demo[0].path_fq
  } : null
}

output "engineering_namespace" {
  description = "Engineering namespace details."
  value = {
    id      = vault_namespace.engineering.namespace_id
    path    = vault_namespace.engineering.path
    path_fq = vault_namespace.engineering.path_fq
  }
}

output "production_namespace" {
  description = "Production namespace details."
  value = {
    id      = vault_namespace.production.namespace_id
    path    = vault_namespace.production.path
    path_fq = vault_namespace.production.path_fq
  }
}

output "team_namespaces" {
  description = "Map of team namespaces with their fully qualified paths."
  value = {
    for team, ns in vault_namespace.teams : team => {
      id      = ns.namespace_id
      path    = ns.path
      path_fq = ns.path_fq
    }
  }
}

output "app_namespaces" {
  description = "Map of application namespaces with their fully qualified paths."
  value = {
    for key, ns in vault_namespace.apps : key => {
      id      = ns.namespace_id
      path    = ns.path
      path_fq = ns.path_fq
    }
  }
}

output "userpass_auth_accessor" {
  description = "Accessor for the userpass auth backend."
  value       = var.enable_userpass_auth ? vault_auth_backend.userpass[0].accessor : null
}

output "userpass_mount_path" {
  description = "Mount path for the userpass auth backend."
  value       = var.enable_userpass_auth ? vault_auth_backend.userpass[0].path : null
}

output "userpass_users" {
  description = "List of userpass usernames created."
  value       = var.enable_userpass_auth ? keys(var.userpass_users) : []
}

output "userpass_passwords" {
  description = "Randomly generated passwords for userpass users. SENSITIVE - Store securely!"
  value = var.enable_userpass_auth ? {
    for username in keys(var.userpass_users) : username => random_password.userpass_passwords[username].result
  } : null
  sensitive = true
}

output "approle_auth_paths" {
  description = "Map of AppRole auth backend paths in each namespace."
  value = var.enable_approle_auth ? {
    admin       = vault_auth_backend.approle_admin[0].path
    engineering = vault_auth_backend.approle_engineering[0].path
    production  = vault_auth_backend.approle_production[0].path
    teams = {
      for team in var.teams : team => vault_auth_backend.approle_teams[team].path
    }
    apps = {
      for key in keys(vault_auth_backend.approle_apps) : key => vault_auth_backend.approle_apps[key].path
    }
  } : null
}

output "approle_roles" {
  description = "Map of AppRole role names in each namespace."
  value = var.enable_approle_auth ? {
    admin       = vault_approle_auth_backend_role.admin_automation[0].role_name
    engineering = vault_approle_auth_backend_role.engineering_automation[0].role_name
    production  = vault_approle_auth_backend_role.production_automation[0].role_name
    teams = {
      for team in var.teams : team => vault_approle_auth_backend_role.team_automation[team].role_name
    }
    apps = {
      for key in keys(vault_approle_auth_backend_role.app_role) : key => vault_approle_auth_backend_role.app_role[key].role_name
    }
  } : null
}

output "fake_roles_summary" {
  description = "Summary of fake roles created for entity count testing."
  value = var.enable_approle_auth && var.create_fake_roles ? {
    admin_fake_roles       = var.fake_roles_count
    engineering_fake_roles = var.fake_roles_count
    production_fake_roles  = var.fake_roles_count
    team_fake_roles        = length(var.teams) * var.fake_roles_count
    app_fake_roles         = length(var.teams) * length(var.apps) * var.fake_roles_count
    total_fake_roles       = (3 + length(var.teams) + (length(var.teams) * length(var.apps))) * var.fake_roles_count
  } : null
}
