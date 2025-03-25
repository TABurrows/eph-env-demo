# ###################### SELF-SERVICE WORKFLOW #################################
# Define Workflow Variables
variable "delete_workflow_name" {
  type        = string
  description = "Name of the on-demand delete workflow"
}
variable "delete_workflow_description" {
  type        = string
  description = "Description of the on-demand delete workflow"
}
# Define Service Account Variables
variable "delete_workflow_svc_acc_name" {
  type = string
}
variable "delete_workflow_svc_acc_display_name" {
  type = string
}
variable "delete_workflow_svc_acc_description" {
  type = string
}



# Define Service Account
resource "google_service_account" "delete_workflow" {
  project      = google_project.management.project_id
  account_id   = var.delete_workflow_svc_acc_name
  display_name = var.delete_workflow_svc_acc_display_name
  description  = var.delete_workflow_svc_acc_description
}
# Grant permission to the On-Demand Delete Workflow SA to call project delete API
resource "google_folder_iam_member" "project_deleter" {
  folder = google_folder.projects.id
  role   = "roles/resourcemanager.projectDeleter"
  member = "serviceAccount:${google_service_account.delete_workflow.email}"
}
# Grant permission to the On-Demand Delete Workflow SA to write to Firestore
resource "google_project_iam_member" "delete_firestore" {
  project = google_project.management.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.delete_workflow.email}"
}
# Grant permission to the On-Demand Delete Workflow SA to write logs
resource "google_project_iam_member" "delete_logwriter" {
  project = google_project.management.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.delete_workflow.email}"
}



# Define Workflow
module "delete_workflow" {
  source = "./modules/workflow"

  # Define Workflow Values
  workflow_name            = var.delete_workflow_name
  workflow_project         = google_project.management.project_id
  workflow_region          = var.region_id
  workflow_description     = var.delete_workflow_description
  workflow_service_account = google_service_account.delete_workflow.id
  workflow_labels          = var.common_labels

  # Import main workflow YAML file
  workflow_yaml_path = "${path.module}/workflows/delete.workflows.yaml"

  # Dependencies
  depends_on = [
    google_project_service.workflows,
    google_service_account.delete_workflow,
    google_firestore_database.datastore
  ]

}