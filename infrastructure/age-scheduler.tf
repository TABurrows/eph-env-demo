# ###################### AGE SCHEDULER #################################
# Define Variables
variable "age_scheduler_job_name" {
  type = string
}
variable "age_scheduler_job_description" {
  type = string
}
variable "age_scheduler_job_schedule" {
  type = string
}
variable "age_scheduler_job_time_zone" {
  type = string
}
variable "age_scheduler_job_attempt_deadline" {
  type    = string
  default = "180s"
}
# Define Service Account Variables
variable "age_scheduler_svc_acc_name" {
  type = string
}
variable "age_scheduler_svc_acc_display_name" {
  type = string
}
variable "age_scheduler_svc_acc_description" {
  type = string
}



# Define Service Account
resource "google_service_account" "age_scheduler" {
  project      = google_project.management.project_id
  account_id   = var.age_scheduler_svc_acc_name
  display_name = var.age_scheduler_svc_acc_display_name
  description  = var.age_scheduler_svc_acc_description
}
# Grant permission to the Workflows SA to invoke Workflows
resource "google_project_iam_member" "age_scheduler_workflow_invoker" {
  project = google_project.management.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.age_scheduler.email}"
}



# Create Resource
resource "google_cloud_scheduler_job" "age_scheduler_job" {
  project          = google_project.management.project_id
  name             = var.age_scheduler_job_name
  description      = var.age_scheduler_job_description
  schedule         = var.age_scheduler_job_schedule
  time_zone        = var.age_scheduler_job_time_zone
  attempt_deadline = var.age_scheduler_job_attempt_deadline

  # Execute a workflow on Scheduler invocation
  http_target {

    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/projects/${google_project.management.project_id}/locations/${var.region_id}/workflows/${var.age_milestones_workflow_name}/executions"

    oauth_token {
      service_account_email = google_service_account.age_scheduler.email
    }

  }

  depends_on = [
    google_workflows_workflow.age_milestones_workflow
  ]

}