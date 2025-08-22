data "terraform_remote_state" "tfe-infra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}

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

provider "tfe" {
  hostname = data.terraform_remote_state.tfe-infra.outputs.tfe_hostname
  token    = data.terraform_remote_state.admin_token.outputs.token
}

resource "tfe_organization" "test-org" {
  name  = data.terraform_remote_state.tfe-infra.outputs.tfe_org_name
  email = "${data.terraform_remote_state.tfe-infra.outputs.tfe_admin_email}"
}

resource "tfe_workspace" "test" {
  name         = "${data.terraform_remote_state.tfe-infra.outputs.tfe_workspace_name}"
  organization = "${tfe_organization.test-org.name}"
}

output "tfe_org_name" {
  value = tfe_organization.test-org.name
}

output "tfe_workspace_name" {
  value = tfe_workspace.test.name
}