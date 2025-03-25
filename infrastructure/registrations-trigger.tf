# ###################### REGISTRATIONS TRIGGER #################################
# Define Variables
variable "registrations_trigger_name" {
  type = string
}


# Create Resource
resource "google_eventarc_trigger" "registrations_trigger" {
  name     = var.registrations_trigger_name
  location = var.region_id
  project  = google_project.management.project_id

  # Define acceptable messages
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }

  transport {
    pubsub {
      topic = google_pubsub_topic.registrations_topic.id
    }
  }

  # Message destination
  destination {
    workflow = google_workflows_workflow.registrations_workflow.id
  }

  # Define Service Account
  service_account = google_service_account.triggers.email


  # Dependencies
  depends_on = [
    google_project_service.eventarc,
    google_service_account.triggers,
    google_workflows_workflow.registrations_workflow,
    google_pubsub_topic.registrations_topic
  ]

  # Labels
  labels = var.common_labels

}
