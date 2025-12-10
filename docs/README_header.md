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

- **VAULT_TOKEN**: Set the `VAULT_TOKEN` environment variable with a valid Vault token
- **VAULT_ADDR**: Set the `VAULT_ADDR` environment variable to your Vault server address (e.g., `https://vault.example.com:8200`)
- **VAULT_NAMESPACE**: Set to `admin` to provision resources in the admin namespace

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
