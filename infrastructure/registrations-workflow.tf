# ###################### REGISTRATIONS WORKFLOW #################################
# Define Registrations Workflow Variables
variable "registrations_workflow_name" {
  type = string
}
variable "registrations_workflow_description" {
  type = string
}
variable "registrant_iam_role_grant" {
  type = string
}
variable "eph_env_billing_account_id" {
  type = string
}



# Define the Workflow
resource "google_workflows_workflow" "registrations_workflow" {

  # Define Workflow Values
  name            = var.registrations_workflow_name
  project         = google_project.management.project_id
  region          = var.region_id
  description     = var.registrations_workflow_description
  service_account = google_service_account.workflows.id

  # Define Workflow YAML file
  source_contents = templatefile("${path.module}/workflows/registrations.workflows.yaml",
  { registrant_iam_role = var.registrant_iam_role_grant, billing_account_id = var.eph_env_billing_account_id })

  # Define Labels
  labels = var.common_labels

  # Dependencies
  depends_on = [
    google_project_service.workflows,
    google_service_account.workflows,
    google_firestore_database.datastore
  ]

}