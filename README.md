<!-- BEGIN_TF_DOCS -->
# HCPVault-Reporting

This Terraform module provisions a hierarchical namespace structure for HashiCorp Vault Enterprise, following organizational best practices for multi-team environments. It configures both userpass authentication in the admin namespace and AppRole authentication in all namespaces for application and automation workflows.

## Permissions

The following Vault permissions are required to provision resources:

- `sys/namespaces/*` - Create and manage namespaces
- `sys/auth/*` - Mount and configure authentication methods
- `auth/userpass/*` - Create and manage userpass users
- `auth/approle/*` - Create and manage AppRole roles
- Read/Write permissions on the admin namespace
- Administrative access to create nested namespace hierarchies

## Authentication

Authentication to Vault can be configured using one of the following methods:

- **VAULT\_TOKEN**: Set the `VAULT_TOKEN` environment variable with a valid Vault token
- **VAULT\_ADDR**: Set the `VAULT_ADDR` environment variable to your Vault server address (e.g., `https://vault.example.com:8200`)
- **VAULT\_NAMESPACE**: Set to `admin` to provision resources in the admin namespace

Example:
```bash
export VAULT_ADDR="https://vault.example.com:8200"
export VAULT_TOKEN="your-vault-token"
export VAULT_NAMESPACE="admin"
```

## Features

- **Hierarchical Namespace Structure**: Creates a multi-level namespace hierarchy for organizational separation
- **Userpass Authentication**: Configures username/password authentication in the existing admin namespace
- **AppRole Authentication**: Configures AppRole auth method in each namespace for application and automation workflows
- **User Management**: Creates multiple users with configurable passwords and policies
- **Organizational Namespaces**: Top-level namespaces for departments (engineering) and environments (production)
- **Team Namespaces**: Child namespaces under engineering for different teams (platform, security, data)
- **Application Namespaces**: Nested namespaces for applications under each team (frontend, backend, api)
- **Custom Metadata**: Rich metadata tagging for namespace organization and tracking (requires Vault 1.12+)
- **Flexible Configuration**: Configurable team and application lists via variables
- **Fully Qualified Path Outputs**: Complete path information for provisioning resources in child namespaces

## Namespace Hierarchy

The module creates the following namespace structure:

```
admin/ (existing - where you're authenticated)
├── userpass/
│   ├── admin user
│   ├── engineer user
│   └── operator user
├── approle/ (admin-automation role)
├── demo (optional)
├── engineering/
│   ├── approle/ (engineering-automation role)
│   ├── platform/
│   │   ├── approle/ (platform-automation role)
│   │   ├── app-frontend/
│   │   │   └── approle/ (app-frontend-role)
│   │   ├── app-backend/
│   │   │   └── approle/ (app-backend-role)
│   │   └── app-api/
│   │       └── approle/ (app-api-role)
│   ├── security/
│   │   ├── approle/ (security-automation role)
│   │   ├── app-frontend/
│   │   │   └── approle/ (app-frontend-role)
│   │   ├── app-backend/
│   │   │   └── approle/ (app-backend-role)
│   │   └── app-api/
│   │       └── approle/ (app-api-role)
│   └── data/
│       ├── approle/ (data-automation role)
│       ├── app-frontend/
│       │   └── approle/ (app-frontend-role)
│       ├── app-backend/
│       │   └── approle/ (app-backend-role)
│       └── app-api/
│           └── approle/ (app-api-role)
└── production/
    └── approle/ (production-automation role)
```

## Default Users

The module creates the following default users in the admin namespace (passwords should be changed):

- **admin**: Administrative user with admin and default policies
- **engineer**: Engineering user with engineering and default policies
- **operator**: Operations user with operator and default policies

## AppRole Configuration

AppRole authentication is configured in each namespace with the following characteristics:

- **Admin Namespace**: `admin-automation` role for administrative automation
- **Engineering Namespace**: `engineering-automation` role for engineering workflows
- **Production Namespace**: `production-automation` role with tighter security (30m default TTL)
- **Team Namespaces**: Each team gets its own AppRole for team-level automation
- **Application Namespaces**: Each application gets its own AppRole with application-specific policies

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.0.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6)

- <a name="requirement_vault"></a> [vault](#requirement\_vault) (5.7.0)

## Modules

No modules.

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_apps"></a> [apps](#input\_apps)

Description: Set of application names to create as child namespaces under each team namespace.

Type: `set(string)`

Default:

```json
[
  "app-frontend",
  "app-backend",
  "app-api"
]
```

### <a name="input_create_fake_roles"></a> [create\_fake\_roles](#input\_create\_fake\_roles)

Description: Create fake AppRole roles for entity count testing and reporting.

Type: `bool`

Default: `true`

### <a name="input_enable_approle_auth"></a> [enable\_approle\_auth](#input\_enable\_approle\_auth)

Description: Enable the AppRole authentication method in all namespaces.

Type: `bool`

Default: `true`

### <a name="input_enable_demo_namespace"></a> [enable\_demo\_namespace](#input\_enable\_demo\_namespace)

Description: Enable the creation of a demo namespace.

Type: `bool`

Default: `true`

### <a name="input_enable_userpass_auth"></a> [enable\_userpass\_auth](#input\_enable\_userpass\_auth)

Description: Enable the userpass authentication method in the admin namespace.

Type: `bool`

Default: `true`

### <a name="input_fake_roles_count"></a> [fake\_roles\_count](#input\_fake\_roles\_count)

Description: Number of fake roles to create in each AppRole auth backend.

Type: `number`

Default: `1`

### <a name="input_namespace_custom_metadata"></a> [namespace\_custom\_metadata](#input\_namespace\_custom\_metadata)

Description: Custom metadata describing namespaces. Requires Vault version 1.12+.

Type: `map(string)`

Default:

```json
{
  "managed_by": "terraform",
  "purpose": "organizational_structure"
}
```

### <a name="input_teams"></a> [teams](#input\_teams)

Description: Set of team names to create as child namespaces under the engineering namespace.

Type: `set(string)`

Default:

```json
[
  "platform",
  "security",
  "data"
]
```

### <a name="input_userpass_password_length"></a> [userpass\_password\_length](#input\_userpass\_password\_length)

Description: Length of randomly generated passwords for userpass users.

Type: `number`

Default: `24`

### <a name="input_userpass_users"></a> [userpass\_users](#input\_userpass\_users)

Description: Map of userpass users with their policies. Passwords are automatically generated.

Type:

```hcl
map(object({
    policies = list(string)
  }))
```

Default:

```json
{
  "admin": {
    "policies": [
      "admin",
      "default"
    ]
  },
  "engineer": {
    "policies": [
      "engineering",
      "default"
    ]
  },
  "operator": {
    "policies": [
      "operator",
      "default"
    ]
  }
}
```

## Resources

The following resources are used by this module:

- [random_password.userpass_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
- [vault_approle_auth_backend_role.admin_automation](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/approle_auth_backend_role) (resource)
- [vault_approle_auth_backend_role.admin_fake](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/approle_auth_backend_role) (resource)
- [vault_approle_auth_backend_role.app_fake](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/approle_auth_backend_role) (resource)
- [vault_approle_auth_backend_role.app_role](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/approle_auth_backend_role) (resource)
- [vault_approle_auth_backend_role.engineering_automation](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/approle_auth_backend_role) (resource)
- [vault_approle_auth_backend_role.engineering_fake](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/approle_auth_backend_role) (resource)
- [vault_approle_auth_backend_role.production_automation](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/approle_auth_backend_role) (resource)
- [vault_approle_auth_backend_role.production_fake](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/approle_auth_backend_role) (resource)
- [vault_approle_auth_backend_role.team_automation](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/approle_auth_backend_role) (resource)
- [vault_approle_auth_backend_role.team_fake](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/approle_auth_backend_role) (resource)
- [vault_auth_backend.approle_admin](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/auth_backend) (resource)
- [vault_auth_backend.approle_apps](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/auth_backend) (resource)
- [vault_auth_backend.approle_engineering](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/auth_backend) (resource)
- [vault_auth_backend.approle_production](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/auth_backend) (resource)
- [vault_auth_backend.approle_teams](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/auth_backend) (resource)
- [vault_auth_backend.userpass](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/auth_backend) (resource)
- [vault_generic_endpoint.userpass_users](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/generic_endpoint) (resource)
- [vault_namespace.apps](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/namespace) (resource)
- [vault_namespace.demo](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/namespace) (resource)
- [vault_namespace.engineering](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/namespace) (resource)
- [vault_namespace.production](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/namespace) (resource)
- [vault_namespace.reporting_demo](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/namespace) (resource)
- [vault_namespace.teams](https://registry.terraform.io/providers/hashicorp/vault/5.7.0/docs/resources/namespace) (resource)

## Outputs

The following outputs are exported:

### <a name="output_app_namespaces"></a> [app\_namespaces](#output\_app\_namespaces)

Description: Map of application namespaces with their fully qualified paths.

### <a name="output_approle_auth_paths"></a> [approle\_auth\_paths](#output\_approle\_auth\_paths)

Description: Map of AppRole auth backend paths in each namespace.

### <a name="output_approle_roles"></a> [approle\_roles](#output\_approle\_roles)

Description: Map of AppRole role names in each namespace.

### <a name="output_demo_namespace"></a> [demo\_namespace](#output\_demo\_namespace)

Description: Demo namespace details.

### <a name="output_engineering_namespace"></a> [engineering\_namespace](#output\_engineering\_namespace)

Description: Engineering namespace details.

### <a name="output_fake_roles_summary"></a> [fake\_roles\_summary](#output\_fake\_roles\_summary)

Description: Summary of fake roles created for entity count testing.

### <a name="output_production_namespace"></a> [production\_namespace](#output\_production\_namespace)

Description: Production namespace details.

### <a name="output_reporting_demo_namespace"></a> [reporting\_demo\_namespace](#output\_reporting\_demo\_namespace)

Description: Root reporting-demo namespace details.

### <a name="output_team_namespaces"></a> [team\_namespaces](#output\_team\_namespaces)

Description: Map of team namespaces with their fully qualified paths.

### <a name="output_userpass_auth_accessor"></a> [userpass\_auth\_accessor](#output\_userpass\_auth\_accessor)

Description: Accessor for the userpass auth backend.

### <a name="output_userpass_mount_path"></a> [userpass\_mount\_path](#output\_userpass\_mount\_path)

Description: Mount path for the userpass auth backend.

### <a name="output_userpass_passwords"></a> [userpass\_passwords](#output\_userpass\_passwords)

Description: Randomly generated passwords for userpass users. SENSITIVE - Store securely!

### <a name="output_userpass_users"></a> [userpass\_users](#output\_userpass\_users)

Description: List of userpass usernames created.

<!-- markdownlint-enable -->
## External Documentation

This Terraform configuration is based on the official HashiCorp documentation:

- [Vault Namespace Resource Documentation](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/namespace)
- [Vault Enterprise Namespaces](https://www.vaultproject.io/docs/enterprise/namespaces)
- [Codify Management of Vault Enterprise Using Terraform Tutorial](https://learn.hashicorp.com/tutorials/vault/codify-mgmt-enterprise)
<!-- END_TF_DOCS -->