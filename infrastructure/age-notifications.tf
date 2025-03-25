# ###################### age-milestones-wflow.tf #################################
# Define Variables
variable "age_notifications_workflow_name" {
  type = string
}
variable "age_notifications_workflow_description" {
  type = string
}
# Define Service Account Variables
variable "age_notifications_workflow_svc_acc_name" {
  type = string
}
variable "age_notifications_workflow_svc_acc_dipslay_name" {
  type = string
}
variable "age_notifications_workflow_svc_acc_description" {
  type = string
}



# Define Service Account
resource "google_service_account" "age_notifications_workflow" {
  project      = google_project.management.project_id
  account_id   = var.age_notifications_workflow_svc_acc_name
  display_name = var.age_notifications_workflow_svc_acc_dipslay_name
  description  = var.age_notifications_workflow_svc_acc_description
}
# Define Service Account permissions
resource "google_project_iam_member" "age_notifications_workflow_logwriter" {
  project = google_project.management.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.age_notifications_workflow.email}"
}
# Grant permission to the Workflows SA to invoke Workflows
resource "google_project_iam_member" "age_notifications_workflow_invoker" {
  project = google_project.management.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.age_notifications_workflow.email}"
}



# Define the Workflow
resource "google_workflows_workflow" "age_notifications_workflow" {

  # Define Workflow Values
  name            = var.age_notifications_workflow_name
  project         = google_project.management.project_id
  region          = var.region_id
  description     = var.age_notifications_workflow_description
  service_account = google_service_account.age_notifications_workflow.id

  # Define Workflow YAML file
  source_contents = templatefile("${path.module}/workflows/age.notifications.workflows.yaml", { send_email_workflow_id = var.email_workflow_name })

  # Define Labels
  labels = var.common_labels

  # Dependencies
  depends_on = [
    google_project_service.workflows,
    google_service_account.age_notifications_workflow
  ]

}