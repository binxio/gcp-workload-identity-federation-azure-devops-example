resource "google_iam_workload_identity_pool" "example" {
  project = var.project_id

  workload_identity_pool_id = "example"
  display_name              = "example"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "azure_devops_organization" {
  project = var.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.example.workload_identity_pool_id
  workload_identity_pool_provider_id = "ado-${lower(var.azure_devops_organization_name)}"
  display_name                       = "ado/${var.azure_devops_organization_name}"
  disabled                           = false

  attribute_mapping = {
    "google.subject" = "assertion.sub"                                                                                                 # sc://organization/project/service-connection
    "attribute.org"  = "assertion.sub.extract('sc://{organization}/')"                                                                 # organization
    "attribute.proj" = "assertion.sub.extract('sc://{organization}/') + '/' + (assertion.sub.extract('sc://{conn}')).split('/', 3)[1]" # organization/project
    "attribute.conn" = "assertion.sub.extract('sc://{conn}')"                                                                          # organization/project/service-connection
  }

  oidc {
    issuer_uri = "https://vstoken.dev.azure.com/${var.azure_devops_organization_id}"
    allowed_audiences = [
      "api://AzureADTokenExchange"
    ]
  }
}

resource "google_service_account" "azure_devops_project" {
  project      = var.project_id
  account_id   = "ado-${lower(var.azure_devops_project_name)}"
  display_name = "ado/${var.azure_devops_organization_name}/${var.azure_devops_project_name}"
}

# All pipelines from a specific project
resource "google_service_account_iam_member" "azure_devops_project_workload_identity_user_azure_devops_organization" {
  service_account_id = google_service_account.azure_devops_project.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.azure_devops_organization.name}/attribute.proj/${var.azure_devops_organization_name}/${var.azure_devops_project_name}"
}

resource "google_project_iam_member" "azure_devops_project_project_viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.azure_devops_project.email}"
}
