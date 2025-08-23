# use terraform_remote_state data source to fetch outputs from the TFE infrastructure
data "terraform_remote_state" "tfe-infra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}

# mastercard restapi provider for API calls
terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.18"
    }
  }
}

# Configure the REST API Provider
provider "restapi" {
  uri                  = "https://${data.terraform_remote_state.tfe-infra.outputs.tfe_hostname}"
  write_returns_object = true

  headers = {
    Content-Type = "application/json"
  }
}

# Create the payload json and make the API call to create the initial admin user
resource "restapi_object" "initial_admin" {
  path         = "/admin/initial-admin-user?token=${data.terraform_remote_state.tfe-infra.outputs.iact_token}"
  id_attribute = "status"

  data = jsonencode({
    username = "${data.terraform_remote_state.tfe-infra.outputs.tfe_admin_user}"
    email    = "${data.terraform_remote_state.tfe-infra.outputs.tfe_admin_email}"
    password = "${data.terraform_remote_state.tfe-infra.outputs.tfe_admin_password}"
  })
}

# Capture the admin user token from the API response, this works once and only if the user is created successfully
output "token" {
  value     = jsondecode(restapi_object.initial_admin.api_response).token
  sensitive = true
}
