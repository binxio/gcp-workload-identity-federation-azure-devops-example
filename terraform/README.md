# Azure DevOps Workload Identity Pool Example

This Terraform configuration deploys a Workload Identity Pool provider for Azure DevOps issued OIDC tokens.

## Azure DevOps Tokens

Azure DevOps tokens are issued by a specific organization and for a fixed audience.

```hcl
  oidc {
    issuer_uri = "https://vstoken.dev.azure.com/${var.azure_devops_organization_id}"
    allowed_audiences = [
      "api://AzureADTokenExchange"
    ]
  }
```

> Find your Azure DevOps organization id via the [Accounts API](https://learn.microsoft.com/en-us/rest/api/azure/devops/account/accounts/list) by using [this Python snippet](https://github.com/binxio/list-azure-devops-account-ids).

## Trusting Azure DevOps Tokens

Issued tokens are bound to a Service Connection: the `sub`-assertion maps to `sc://<organization>/<project>/<service-connection-name>`.

To trust pipelines with access to the Service connection, use the following principal:

```hcl
resource "google_service_account_iam_member" "azure_devops_project_workload_identity_user_azure_devops_organization" {
  service_account_id = google_service_account.azure_devops_project.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.azure_devops_organization.name}/subject/sc://my-organization/my-project/my-connection"
}
```

To trust all pipelines from a project, use the following principal:

```hcl
resource "google_service_account_iam_member" "azure_devops_project_workload_identity_user_azure_devops_organization" {
  service_account_id = google_service_account.azure_devops_project.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.azure_devops_organization.name}/attribute.proj/my-organization/my-project"
}
```

To trust all pipelines from an organization, use the following principal:

```hcl
resource "google_service_account_iam_member" "azure_devops_project_workload_identity_user_azure_devops_organization" {
  service_account_id = google_service_account.azure_devops_project.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.azure_devops_organization.name}/attribute.org/my-organization"
}
```

## Deploy

1. Configure the required [variables](./variables.tf)

2. Deploy using Terraform

```bash
terraform init
terraform apply
```