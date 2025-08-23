# Use terraform_remote_state data source to fetch outputs from the TFE infrastructure
data "terraform_remote_state" "tfe-infra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}

terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
}


# Use local file resource to create the health check  bash script
resource "local_file" "check_check_script" {
  filename = "./tfe_health_check.sh"
  content  = <<-EOT
    #!/bin/bash

    echo "Waiting for TFE at https://${data.terraform_remote_state.tfe-infra.outputs.tfe_hostname} to be ready..."

    while [ "$(curl -fsS "${data.terraform_remote_state.tfe-infra.outputs.tfe_hostname}/_health_check" )" != "OK" ]; do
      echo "$(date +"%Y-%m-%d %H:%M:%S") Waiting TFE to start..."
      sleep 30
    done

    echo "$(date +"%Y-%m-%d %H:%M:%S") TFE is ready!"
  EOT
}

# Null resource to run the health check script 
resource "null_resource" "run_script" {
  provisioner "local-exec" {
    command = "bash ${local_file.check_check_script.filename}"
  }
}

# Create terraform configuration file for the remote execution example on TFE
resource "local_file" "null_tf_file" {
  filename = "../03-example-cli-driven-ws/null.tf"
  content  = <<-EOT
        terraform {
          cloud {
            hostname     = "${data.terraform_remote_state.tfe-infra.outputs.tfe_hostname}"
            organization = "${data.terraform_remote_state.tfe-infra.outputs.tfe_org_name}"
            workspaces {
              name = "${data.terraform_remote_state.tfe-infra.outputs.tfe_workspace_name}"
            }
          }  
        }

        module "null_resources" {
            source = "git::https://github.com/StamatisChr/mynull.git"
        }
    EOT
}

output "tfe_status" {
  value = "TFE is ready!"
}