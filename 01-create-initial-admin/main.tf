data "terraform_remote_state" "tfe-infra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}

terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.18"
    }
  }
}

provider "restapi" {
  uri                  = data.terraform_remote_state.tfe-infra.outputs.tfe-docker-fqdn
  write_returns_object = true

  headers = {
    Content-Type = "application/json"
  }
}

resource "restapi_object" "initial_admin" {
  path         = "/admin/initial-admin-user?token=${data.terraform_remote_state.tfe-infra.outputs.iact_token}"
  id_attribute = "status"

  data = jsonencode({
    username = "${data.terraform_remote_state.tfe-infra.outputs.tfe_admin_user}"
    email    = "${data.terraform_remote_state.tfe-infra.outputs.tfe_admin_email}"
    password = "${data.terraform_remote_state.tfe-infra.outputs.tfe_admin_password}"
  })
}

output "token" {
  value     = jsondecode(restapi_object.initial_admin.api_response).token
  sensitive = true
}
