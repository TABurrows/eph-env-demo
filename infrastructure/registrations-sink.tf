# ###################### REGISTRATIONS SINK #################################
# Define Variables
variable "registrations_sink_name" {
  type = string
}
variable "registrations_sink_description" {
  type = string
}
variable "registrations_sink_filter" {
  type = string
}


# Create Resource
resource "google_logging_folder_sink" "registrations_sink" {
  name        = var.registrations_sink_name
  description = var.registrations_sink_description
  folder      = google_folder.projects.id

  # Can export to pubsub, cloud storage, or bigquery
  destination = "pubsub.googleapis.com/projects/${google_project.management.project_id}/topics/${var.registrations_topic_name}"

  # Log all WARN or higher severity messages relating to instances
  filter = var.registrations_sink_filter

  # Dependencies
  depends_on = [
    google_project_service.eventarc,
    google_pubsub_topic.registrations_topic
  ]

}