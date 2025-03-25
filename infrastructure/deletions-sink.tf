# ###################### DELETIONS SINK #################################
# Define Variables
variable "deletions_sink_name" {
  type = string
}
variable "deletions_sink_description" {
  type = string
}
variable "deletions_sink_filter" {
  type = string
}



# Create Resource
resource "google_logging_folder_sink" "deletions_sink" {
  name        = var.deletions_sink_name
  description = var.deletions_sink_description
  folder      = google_folder.projects.id

  # Can export to pubsub, cloud storage, or bigquery
  destination = "pubsub.googleapis.com/${google_pubsub_topic.deletions_topic.id}"

  # Log all WARN or higher severity messages relating to instances
  filter = var.deletions_sink_filter

  # Dependencies
  depends_on = [
    google_project_service.eventarc,
    google_pubsub_topic.deletions_topic
  ]

}