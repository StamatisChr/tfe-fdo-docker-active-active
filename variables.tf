variable "aws_region" {
  description = "The AWS region in use to spawn the resources"
  type        = string
}

variable "tfe_instance_class" {
  description = "The ec2 instance type for TFE"
  type        = string
  default     = "t3.xlarge"
}

variable "db_instance_class" {
  description = "The rds instance class for TFE"
  type        = string
  default     = "db.t3.large"
}

variable "hosted_zone_name" {
  description = "The zone ID of my doormat hosted route53 zone"
  type        = string
}

variable "tfe_license" {
  description = "your TFE license string"
  type        = string
}

variable "tfe_http_port" {
  description = "TFE container http port"
  type        = number
  default     = 80
}

variable "tfe_https_port" {
  description = "TFE container https port"
  type        = number
  default     = 443
}

variable "tfe_encryption_password" {
  description = "TFE encryption password"
  type        = string
}

variable "tfe_version_image" {
  description = "The desired TFE version, example value: v202410-1"
  type        = string
}

variable "tfe_host_path_to_certificates" {
  description = "The path on the host machine to store the certificate files"
  type        = string
  default     = "/etc/terraform-enterprise/certs"
}

variable "lets_encrypt_cert" {
  description = "value"
  type        = string
  default     = "fullchain1.pem"

}

variable "lets_encrypt_key" {
  description = "value"
  type        = string
  default     = "privkey1.pem"
}

variable "tfe_database_user" {
  description = "The user of the database in the RDS instance"
  type        = string
  default     = "tfeadmin"
}

variable "tfe_database_name" {
  description = "The database name in the RDS instance"
  type        = string
  default     = "terraform"
}

variable "tfe_database_password" {
  description = "The database password of the database name in the RDS instance"
  type        = string
}

variable "tfe_dns_record" {
  description = "The DNS record for the TFE instance"
  type        = string
  default     = "tfe-docker-aa"
}