# ###################### Create Secret Values #################################
# Define Variables
variable "sendgrid_api_key_id" {
  type = string
}
variable "sendgrid_api_key_value" {
  type = string
}


# Create Sendgrid API Key Secret
resource "google_secret_manager_secret" "sendgrid_api_key_secret" {
  project   = google_project.management.project_id
  secret_id = var.sendgrid_api_key_id

  replication {
    user_managed {
      replicas {
        location = "europe-west2"
      }
    }
  }

  depends_on = [
    google_project_service.secrets
  ]
}

resource "google_secret_manager_secret_version" "sendgrid_api_key_secret_version" {
  secret = google_secret_manager_secret.sendgrid_api_key_secret.id

  secret_data     = var.sendgrid_api_key_value
  deletion_policy = "ABANDON"
}