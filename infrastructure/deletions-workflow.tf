# ###################### DELETIONS WORKFLOW #################################
# Define Deletions Workflow Variables
variable "deletions_workflow_name" {
  type = string
}
variable "deletions_workflow_description" {
  type = string
}

# Define Deletions Workflow
resource "google_workflows_workflow" "deletions_workflow" {
  project         = google_project.management.project_id
  name            = var.deletions_workflow_name
  region          = var.region_id
  description     = var.deletions_workflow_description
  service_account = google_service_account.workflows.id

  # Imported main workflow YAML file
  source_contents = templatefile("${path.module}/workflows/deletions.workflows.yaml", { eph_env_email_workflow_id : var.email_workflow_name })

  # Dependencies
  depends_on = [
    google_project_service.workflows,
    google_service_account.workflows,
    google_firestore_database.datastore
  ]

  # Labels
  labels = var.common_labels
}