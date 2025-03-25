# ###################### DELETIONS TRIGGER #################################
# Define Variables
variable "deletions_trigger_name" {
  type = string
}


# Create Resource
resource "google_eventarc_trigger" "deletions_trigger" {
  name     = var.deletions_trigger_name
  location = var.region_id
  project  = google_project.management.project_id

  # Define acceptable messages
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }

  transport {
    pubsub {
      topic = google_pubsub_topic.deletions_topic.id
    }
  }

  # Message destination
  destination {
    workflow = google_workflows_workflow.deletions_workflow.id
  }

  # Define Service Account
  service_account = google_service_account.triggers.email


  # Dependencies
  depends_on = [
    google_project_service.eventarc,
    google_service_account.triggers,
    google_workflows_workflow.deletions_workflow,
    google_pubsub_topic.deletions_topic
  ]

  # Labels
  labels = var.common_labels

}
