# ###################### REGISTRATIONS TOPIC #################################
# Define Variables
variable "registrations_topic_name" {
  type = string
}
variable "deletions_topic_name" {
  type = string
}
variable "pubsub_message_retention_secs" {
  type    = string
  default = "82800s" # make the max message retention 23 Hours
}


# Create Regitrations Topic Resource
resource "google_pubsub_topic" "registrations_topic" {

  project                    = google_project.management.project_id
  name                       = var.registrations_topic_name
  message_retention_duration = var.pubsub_message_retention_secs

  # Dependencies
  depends_on = [
    google_project_service.pubsub,
    google_workflows_workflow.registrations_workflow
  ]

  # Labels
  labels = var.common_labels
}



# Create Deletions Topic Resource
resource "google_pubsub_topic" "deletions_topic" {

  project                    = google_project.management.project_id
  name                       = var.deletions_topic_name
  message_retention_duration = var.pubsub_message_retention_secs

  # Dependencies
  depends_on = [
    google_project_service.pubsub,
    google_workflows_workflow.deletions_workflow
  ]

  # Labels
  labels = var.common_labels
}