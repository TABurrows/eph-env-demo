# ###################### age-milestones-wflow.tf #################################
# Define Variables
variable "age_milestones_workflow_name" {
  type = string
}
variable "age_milestones_workflow_description" {
  type = string
}
# Define Service Account Variables
variable "age_milestones_workflow_svc_acc_name" {
  type = string
}
variable "age_milestones_workflow_svc_acc_display_name" {
  type = string
}
variable "age_milestones_workflow_svc_acc_description" {
  type = string
}




# Define Service Account
resource "google_service_account" "age_milestones_workflow" {
  project      = google_project.management.project_id
  account_id   = var.age_milestones_workflow_svc_acc_name
  display_name = var.age_milestones_workflow_svc_acc_display_name
  description  = var.age_milestones_workflow_svc_acc_description
}
# Define Service Account permissions
resource "google_project_iam_member" "age_milestones_workflow_logwriter" {
  project = google_project.management.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.age_milestones_workflow.email}"
}
# Grant permission to use Firestore
resource "google_project_iam_member" "age_milestones_workflow_firestore" {
  project = google_project.management.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.age_milestones_workflow.email}"
}
# Grant permission to invoke workflows
resource "google_project_iam_member" "age_milestones_workflow_invoker" {
  project = google_project.management.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.age_milestones_workflow.email}"
}




# Define the Workflow
resource "google_workflows_workflow" "age_milestones_workflow" {

  # Define Workflow Values
  name            = var.age_milestones_workflow_name
  project         = google_project.management.project_id
  region          = var.region_id
  description     = var.age_milestones_workflow_description
  service_account = google_service_account.age_milestones_workflow.id

  # Define Workflow YAML file
  source_contents = templatefile("${path.module}/workflows/age.milestones.workflows.yaml", { age_expirations_workflow_id = var.age_expirations_workflow_name, age_notifications_workflow_id = var.age_notifications_workflow_name })

  # Define Labels
  labels = var.common_labels

  # Dependencies
  depends_on = [
    google_project_service.workflows,
    google_service_account.age_milestones_workflow
  ]

}