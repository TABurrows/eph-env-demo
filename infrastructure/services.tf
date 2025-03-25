
# =========================================================================
# Service Resources: services.tf
# =========================================================================
# Resources

# Enable Firestore API
resource "google_project_service" "firestore" {
  project            = google_project.management.project_id
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
}

# Enable Eventarc API
resource "google_project_service" "eventarc" {
  project            = google_project.management.project_id
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

# Enable Pub/Sub API
resource "google_project_service" "pubsub" {
  project            = google_project.management.project_id
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

# Enable Workflows API
resource "google_project_service" "workflows" {
  project            = google_project.management.project_id
  service            = "workflows.googleapis.com"
  disable_on_destroy = false
}

# Enable Secret Manager API
resource "google_project_service" "secrets" {
  project            = google_project.management.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud Scheduler API
resource "google_project_service" "scheduler" {
  project            = google_project.management.project_id
  service            = "cloudscheduler.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud Billing API
resource "google_project_service" "billing" {
  project            = google_project.management.project_id
  service            = "cloudbilling.googleapis.com"
  disable_on_destroy = false
}

# Enable Logging API
resource "google_project_service" "logging" {
  project            = google_project.management.project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud Resource Manager API
resource "google_project_service" "resourcemanager" {
  project            = google_project.management.project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}