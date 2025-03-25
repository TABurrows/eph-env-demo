# ###################### AGE MILESTONES WORKFLOW #################################
# Define Variables
variable "create_workflow_name" {
  type = string
}
variable "create_workflow_description" {
  type = string
}
variable "eph_envs_prefix" {
  type = string
  # validation: no longer than seven lower case characters and hyphens
}
# Define Service Account Variables
variable "create_workflow_svc_acc_name" {
  type = string
}
variable "create_workflow_svc_acc_display_name" {
  type = string
}
variable "create_workflow_svc_acc_description" {
  type = string
}



# Define Service Account
resource "google_service_account" "create_workflow" {
  project      = google_project.management.project_id
  account_id   = var.create_workflow_svc_acc_name
  display_name = var.create_workflow_svc_acc_display_name
  description  = var.create_workflow_svc_acc_description
}
# Grant permission to the Create Workflow SA to call the projects folder's
# project create method
resource "google_folder_iam_member" "project_creator" {
  folder = google_folder.projects.id
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${google_service_account.create_workflow.email}"
}
# Grant permission to the Create Workflow SA to write to Firestore
resource "google_project_iam_member" "create_firestore" {
  project = google_project.management.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.create_workflow.email}"
}
# Grant permission to the Create Workflow SA to write logs
resource "google_project_iam_member" "create_logwriter" {
  project = google_project.management.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.create_workflow.email}"
}


# Define the Workflow
resource "google_workflows_workflow" "creation_workflow" {

  # Define Workflow Values
  name            = var.create_workflow_name
  project         = google_project.management.project_id
  region          = var.region_id
  description     = var.create_workflow_description
  service_account = google_service_account.create_workflow.id

  # Define Workflow YAML file
  source_contents = templatefile("${path.module}/workflows/create.workflows.yaml", { eph_envs_folder_id = google_folder.projects.id, eph_envs_prefix = var.eph_envs_prefix })

  # Define Labels
  labels = var.common_labels

  # Dependencies
  depends_on = [
    google_project_service.workflows,
    google_service_account.create_workflow,
    google_firestore_database.datastore
  ]

}