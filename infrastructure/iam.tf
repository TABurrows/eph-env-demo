# =========================================================================
# IAM Resources:  accounts.tf
# =========================================================================
# Variables



# Define Workflows Account Variables
variable "workflows_service_account_name" {
  type = string
}
variable "workflows_service_account_display_name" {
  type = string
}
variable "workflows_service_account_description" {
  type = string
}

# Define Triggers Account Variables
variable "triggers_service_account_name" {
  type = string
}
variable "triggers_service_account_display_name" {
  type = string
}
variable "triggers_service_account_description" {
  type = string
}

variable "logging_service_agent" {
  type = string
}







# ###################### Create WORKFLOWS SERVICE ACCOUNT #################################
resource "google_service_account" "workflows" {
  project      = google_project.management.project_id
  account_id   = var.workflows_service_account_name
  display_name = var.workflows_service_account_display_name
  description  = var.workflows_service_account_description
}
# Grant permission to the Workflows SA to receive Eventarc events
resource "google_project_iam_member" "eventreceiver" {
  project = google_project.management.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.workflows.email}"
}
# Grant permission to the Workflows SA to write logs
resource "google_project_iam_member" "logwriter" {
  project = google_project.management.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.workflows.email}"
}
# Grant permission to the Workflows SA to write to Firestore
resource "google_project_iam_member" "firestore" {
  project = google_project.management.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.workflows.email}"
}
# Grant permission to the Workflows SA to invoke Workflows
resource "google_project_iam_member" "workflow_invoker" {
  project = google_project.management.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.workflows.email}"
}
# Grant permission to the Workflows SA to get and set IAM Policy
# on Projects that are Descendents of the Parent Folder
resource "google_folder_iam_member" "workflow_iam_policy" {
  folder = google_folder.projects.id
  role   = "roles/resourcemanager.projectIamAdmin"
  member = "serviceAccount:${google_service_account.workflows.email}"
}
# Grant permission to the Workflows SA to get and set Billing
#  Account details for newly created Projects
resource "google_billing_account_iam_member" "workflow_billing_user" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.workflows.email}"
}
# BILLING: Permission granted to associate billing accounts with new projects
resource "google_folder_iam_member" "workflow_billing_project_manager" {
  folder = google_folder.projects.id
  role   = "roles/billing.projectManager"
  member = "serviceAccount:${google_service_account.workflows.email}"
}
# # APIs: Permission grant to allow the APIs to be enabled in the new projects
# #  eg. to assign Billing, Service Usage API must be enabled within the new project
# resource "google_folder_iam_member" "workflow_service_usage_admin" {
#     folder = "${google_folder.projects.id}"
#     role = "roles/serviceusage.serviceUsageAdmin"
#     member = "serviceAccount:${google_service_account.workflows.email}"
# }




# ###################### Create TRIGGERS SERVICE ACCOUNT #################################
# Create a dedicated service account
resource "google_service_account" "triggers" {
  project      = google_project.management.project_id
  account_id   = var.triggers_service_account_name
  display_name = var.triggers_service_account_display_name
  description  = var.triggers_service_account_description
}
# Grant permission to the Triggers SA to invoke Workflows
resource "google_project_iam_member" "workflows" {
  project = google_project.management.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.triggers.email}"
}
# Grant permission to the Triggers SA to receive eventarc events
resource "google_project_iam_member" "events" {
  project = google_project.management.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.triggers.email}"
}



# ###################### Grant Permission to Cloud Audit Service Agent #################################
# Grant permission for the projects folder's logging Service Agent
# to publish to the management project's pub/sub topics
resource "google_project_iam_binding" "projects_service_agent" {
  project = google_project.management.project_id
  role    = "roles/pubsub.publisher"

  # eg. gcp-sa-logging
  members = [
    "serviceAccount:service-folder-${replace(google_folder.projects.id, "folders/", "")}@${var.logging_service_agent}.iam.gserviceaccount.com",
  ]

  depends_on = [
    google_project.management,
    google_logging_folder_sink.deletions_sink,
    google_logging_folder_sink.registrations_sink,
  ]
}


