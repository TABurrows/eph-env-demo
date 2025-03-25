# ###################### age-expirations-wflow.tf #################################
# Define Variables
variable "age_expirations_workflow_name" {
  type = string
}
variable "age_expirations_workflow_description" {
  type = string
}
# Define Service Account Variables
variable "age_expirations_workflow_svc_acc_name" {
  type = string
}
variable "age_expirations_workflow_svc_acc_dipslay_name" {
  type = string
}
variable "age_expirations_workflow_svc_acc_description" {
  type = string
}



# Define Service Account
resource "google_service_account" "age_expirations_workflow" {
  project      = google_project.management.project_id
  account_id   = var.age_expirations_workflow_svc_acc_name
  display_name = var.age_expirations_workflow_svc_acc_dipslay_name
  description  = var.age_expirations_workflow_svc_acc_description
}
# Define Service Account permissions
resource "google_project_iam_member" "age_expirations_workflow_logwriter" {
  project = google_project.management.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.age_expirations_workflow.email}"
}
# Grant permission to invoke workflows
resource "google_project_iam_member" "age_expirations_workflow_invoker" {
  project = google_project.management.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.age_expirations_workflow.email}"
}



# Define the Workflow
resource "google_workflows_workflow" "age_expirations_workflow" {

  # Define Workflow Values
  name            = var.age_expirations_workflow_name
  project         = google_project.management.project_id
  region          = var.region_id
  description     = var.age_expirations_workflow_description
  service_account = google_service_account.age_expirations_workflow.id

  # Define Workflow YAML file
  source_contents = templatefile("${path.module}/workflows/age.expirations.workflows.yaml", { deletion_workflow_id = var.delete_workflow_name })

  # Define Labels
  labels = var.common_labels

  # Dependencies
  depends_on = [
    google_project_service.workflows,
    google_service_account.age_expirations_workflow
  ]

}

# # Define Workflow
# module "age_expirations_workflow" {
#   source = "./modules/workflow"

#   # Define Workflow values
#   workflow_name            = 
#   workflow_project         = google_project.management.project_id
#   workflow_region          = var.region_id
#   workflow_description     = 
#   workflow_service_account = 
#   workflow_labels          = var.common_labels


#   # Import the main workflow YAML file
#   workflow_yaml_path = "${path.module}/workflows/age.expirations.workflows.yaml"

#   # Dependencies
#   depends_on = [
#     google_project_service.workflows,
#     google_service_account.age_expirations_workflow
#   ]

# }