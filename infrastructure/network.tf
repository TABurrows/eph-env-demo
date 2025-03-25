# =========================================================================
# Network Resources: network.tf
# =========================================================================
# Variables
variable "vpc_name" {
  type = string
}
variable "subnet_prefix" {
  type = string
}
variable "subnet_zone_cidrs" {
  type    = list(string)
  default = ["10.1.1.0/24"]
}
variable "subnet_zone_names" {
  type    = list(string)
  default = ["internal"]
}



# =========================================================================
# Locals
data "google_compute_zones" "main" {
  region  = var.region_id
  project = google_project.management.project_id
}
locals {
  type  = ["internal"]
  zones = data.google_compute_zones.main.names
}



# =========================================================================
# Resources

# VPC
resource "google_compute_network" "main" {
  project                 = google_project.management.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "zones" {
  count = length(var.subnet_zone_cidrs)

  region        = var.region_id
  project       = google_project.management.project_id
  name          = "${var.subnet_prefix}-${var.subnet_zone_names[count.index]}"
  ip_cidr_range = var.subnet_zone_cidrs[count.index]
  network       = google_compute_network.main.id

  # Enable Private Google Access to private subnet zones
  # private_ip_google_access = var.subnet_zone_names[count.index] == "internal" ? true : false

  depends_on = [
    google_compute_network.main
  ]
}

