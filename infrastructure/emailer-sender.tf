# ###################### email.tf #################################
# Define Workflows Variables
variable "email_workflow_name" {
  type = string
}
variable "email_workflow_description" {
  type = string
}
variable "emailer_allowed_recipient_domain" {
  type = string
}
# Define Service Account Variables 
variable "email_workflow_svc_acc_name" {
  type = string
}
variable "email_workflow_svc_acc_display_name" {
  type = string
}
variable "email_workflow_svc_acc_description" {
  type = string
}
# Define Sendgrid variables
variable "sendgrid_api_endpoint" {
  type = string
}
variable "emailer_no_reply_address" {
  type = string
}



# Define Service Account 
resource "google_service_account" "email_workflow" {
  project      = google_project.management.project_id
  account_id   = var.email_workflow_svc_acc_name
  display_name = var.email_workflow_svc_acc_display_name
  description  = var.email_workflow_svc_acc_description
}
# Grant permission to the Email Workflow SA to read Secrets
resource "google_project_iam_member" "secrets" {
  project = google_project.management.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.email_workflow.email}"
}
# Grant permission to the Email Workflow SA to write logs
resource "google_project_iam_member" "email_workflow_logwriter" {
  project = google_project.management.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.email_workflow.email}"
}


# Define the Workflow
resource "google_workflows_workflow" "email_workflow" {

  # Define Workflow Values
  name            = var.email_workflow_name
  project         = google_project.management.project_id
  region          = var.region_id
  description     = var.email_workflow_description
  service_account = google_service_account.email_workflow.id

  # Define Workflow YAML file
  source_contents = templatefile("${path.module}/workflows/email.sendgrid.workflows.yaml",
  { sendgrid_api_key_id = var.sendgrid_api_key_id, sendgrid_api_endpoint = var.sendgrid_api_endpoint, emailer_no_reply_address = var.emailer_no_reply_address, allowed_email_domain = var.emailer_allowed_recipient_domain })

  # Define Labels
  labels = var.common_labels

  # Dependencies
  depends_on = [
    google_project_service.workflows,
    google_service_account.email_workflow,
    google_firestore_database.datastore
  ]

}