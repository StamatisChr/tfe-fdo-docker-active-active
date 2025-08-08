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


output "tfe-fqdn" {
  description = "tfe fqdn"
  value       = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"
}



output "start_aws_ssm_session" {
  value = "aws ssm start-session --target ${aws_instance.tfe_instance.id} --region ${var.aws_region}"
}

output "tfe_version" {
  value = var.tfe_version_image
}
