# =========================== Workflow Module ==============================
# Define Workflow Variables
variable "workflow_name" {
    type = string
}
variable "workflow_project" {
    type = string
}
variable "workflow_region" {
    type = string
}
variable "workflow_description" {
    type = string
}
variable "workflow_service_account" {
    type = string
}
variable "workflow_yaml_path" {
    type = string
}
variable "workflow_labels" {
  type = map(string)
}


# Define the Workflow
resource "google_workflows_workflow" "workflow" {

    name            = var.workflow_name
    project = var.workflow_project
    region          = var.workflow_region
    description     = var.workflow_description
    service_account = var.workflow_service_account

    # Define Workflow YAML file
    source_contents = templatefile(var.workflow_yaml_path, {})

    # Define Labels
    labels = var.workflow_labels

}