output "ubuntu_2404_ami_id" {
  value = data.aws_ami.ubuntu_2404.id

}

output "ubuntu_2404_ami_name" {
  value = data.aws_ami.ubuntu_2404.name

}

output "aws_region" {
  value = var.aws_region

}

output "tfe-docker-fqdn" {
  description = "tfe-fqdn"
  value       = "https://${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"

}

output "tfe_hostname" {
  value = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"
}

output "tfe_health_check" {
  value = "https://${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}/_health_check"

}

output "tfe_version" {
  value = var.tfe_version_image
}

output "iact_token" {
  description = "The IACT token for TFE"
  value       = random_string.iact_token.result
  sensitive   = true
}

output "tfe_admin_user" {
  value = var.tfe_admin_user
}

output "tfe_admin_password" {
  description = "The password for the TFE admin user"
  value       = var.tfe_admin_password
  sensitive   = true
}

output "tfe_admin_email" {
  description = "The email for the TFE admin user"
  value       = var.tfe_admin_email
}

output "tfe_org_name" {
  value = var.tfe_org_name
}

output "tfe_workspace_name" {
  value = var.tfe_workspace_name
}