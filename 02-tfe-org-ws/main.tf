# Use terraform_remote_state data source to fetch outputs from the TFE infrastructure
data "terraform_remote_state" "tfe-infra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}

# Use terraform_remote_state data source to fetch the admin token from the initial admin creation output
data "terraform_remote_state" "admin_token" {
  backend = "local"
  config = {
    path = "../01-create-initial-admin/terraform.tfstate"
  }
}

terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.37"
    }
  }
}

# Configure TFE provider
provider "tfe" {
  hostname = data.terraform_remote_state.tfe-infra.outputs.tfe_hostname
  token    = data.terraform_remote_state.admin_token.outputs.token
}

# Create TFE organization
resource "tfe_organization" "test-org" {
  name  = data.terraform_remote_state.tfe-infra.outputs.tfe_org_name
  email = data.terraform_remote_state.tfe-infra.outputs.tfe_admin_email
}

# Create TFE workspace
resource "tfe_workspace" "test" {
  name         = data.terraform_remote_state.tfe-infra.outputs.tfe_workspace_name
  organization = tfe_organization.test-org.name
}

output "tfe_org_name" {
  value = tfe_organization.test-org.name
}

output "tfe_workspace_name" {
  value = tfe_workspace.test.name
}

output "tfe_admin_user" {
  value = data.terraform_remote_state.tfe-infra.outputs.tfe_admin_user
}

output "tfe_admin_password" {
  value = data.terraform_remote_state.tfe-infra.outputs.tfe_admin_password
}

output "terraform_login" {
  value = "terraform login ${data.terraform_remote_state.tfe-infra.outputs.tfe_hostname}"
}