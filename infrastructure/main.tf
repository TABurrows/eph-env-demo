# =========================================================================
# Entry point: main.tf
# =========================================================================
# Variables
variable "region_id" {
  type        = string
  description = "The region in which to create the resources."
  default     = "europe-west2"
}
variable "root_folder_id" {
  type        = string
  description = "The ID of an existing folder into which terraform will create the base folder"
  validation {
    condition     = can(regex("[0-9]", var.root_folder_id))
    error_message = "The Root Folder ID should be a string of number characters"
  }
}
variable "base_folder_name" {
  type        = string
  description = "value of the base folder name into which all Ephemeral Environment resources will be created. It will be created in the provided existing root folder."
  validation {
    condition     = length(var.base_folder_name) > 3 && length(var.base_folder_name) < 31 && can(regex("^[a-zA-Z0-9 ]+$", var.base_folder_name))
    error_message = "The Base Folder value must be between 4 and 30 letters, numbers or space characters "
  }
}
variable "projects_folder_name" {
  type        = string
  description = "value of the projects folder name"
}
variable "mgmnt_project_id_prefix" {
  type        = string
  description = "value of the ID prefixof the Ephemeral Environments management project"
}
variable "mgmnt_project_name" {
  type        = string
  description = "value of the name of the Ephemeral Environments management project"
}
variable "billing_account_id" {
  type        = string
  description = "value of the billing account ID to be associated with Ephemeral projects"
}
variable "common_labels" {
  type        = map(string)
  description = "value of the common labels applied to created resources"
  default = {
    cost_centre = "eph-envs"
    environment = "development"
  }
}



# =========================================================================
# Create the Management Project ID
resource "random_id" "suffix" {
  byte_length = 2
}
locals {
  project_id = "${var.mgmnt_project_id_prefix}-${random_id.suffix.hex}"
}



# =========================================================================
# Configure provider
provider "google" {
  region  = var.region_id
  project = local.project_id
}



# =========================================================================
# Resources

# Create the base folder under the root folder
resource "google_folder" "base" {
  display_name = var.base_folder_name
  parent       = "folders/${var.root_folder_id}"
}


# Create the projects folder under the base folder
resource "google_folder" "projects" {
  display_name = var.projects_folder_name
  parent       = google_folder.base.id
}


# Create the management project in the base folder
resource "google_project" "management" {
  name            = var.mgmnt_project_name
  project_id      = local.project_id
  folder_id       = google_folder.base.id
  billing_account = var.billing_account_id
  # Note: this enables compute.googleapis.com in the project
  auto_create_network = false

  labels = var.common_labels

  depends_on = [
    google_folder.base
  ]
}