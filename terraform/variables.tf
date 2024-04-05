variable "project_id" {
  description = "Project to deploy to e.g. my-project"
  type        = string
}

variable "azure_devops_organization_id" {
  description = "ID of Azure DevOps organization issuing OIDC tokens. Find it easily using the [accounts api](https://learn.microsoft.com/en-us/rest/api/azure/devops/account/accounts/list), also see [this example](https://github.com/binxio/list-azure-devops-account-ids)"
  type        = string
}

variable "azure_devops_organization_name" {
  description = "Name of Azure DevOps organization issuing OIDC tokens e.g. my-organization"
  type        = string
}

variable "azure_devops_project_name" {
  description = "Name of Azure DevOps project running Pipelines e.g. my-project"
}