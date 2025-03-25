# =========================================================================
# Firestore Resources: firestore.tf
# =========================================================================
# Rources

# Add a delay to overcome the error:
# Error creating Database: googleapi: Error 403: Cloud Firestore API has not been used in project eph-envs-mgmnt-3581 before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=eph-envs-mgmnt-xxxx then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.
resource "null_resource" "prior" {}
resource "time_sleep" "delay_creation" {
  depends_on      = [null_resource.prior]
  create_duration = "240s"
}

# Create a firestore database
resource "google_firestore_database" "datastore" {
  project     = google_project.management.project_id
  name        = "(default)"
  location_id = var.region_id
  type        = "FIRESTORE_NATIVE"
  # app_engine_integration_mode       = "DISABLED"
  # point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_DISABLED"
  # Don't protect the database from deletion by terraform
  delete_protection_state = "DELETE_PROTECTION_DISABLED"
  deletion_policy         = "DELETE"

  depends_on = [
    google_project_service.firestore,
    time_sleep.delay_creation
  ]
}