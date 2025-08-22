# S3 Bucket
locals {
  bucket_names = toset([
    "tfe-data-bucket",
    "tfe-shared-files",
  ])
}

resource "aws_s3_bucket" "tfe_bucket" {
  for_each      = local.bucket_names
  bucket        = "${each.key}-${random_pet.hostname_suffix.id}"
  force_destroy = true

  tags = {
    Name = "${random_pet.hostname_suffix.id}"
  }
}

resource "aws_s3_bucket_public_access_block" "tfe_bucket_access" {
  for_each = aws_s3_bucket.tfe_bucket
  bucket   = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

resource "aws_s3_bucket_versioning" "versioning_example" {
  for_each = aws_s3_bucket.tfe_bucket
  bucket   = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}