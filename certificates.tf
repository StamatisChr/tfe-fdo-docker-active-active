# Generate a private key for the ACME account
resource "tls_private_key" "acme_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.acme_key.private_key_pem
  email_address   = "stamatios.chrysinas@hashicorp.com"
}

# Generate a private key for the SSL certificate
resource "tls_private_key" "cert_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "req" {
  private_key_pem = tls_private_key.cert_key.private_key_pem
  dns_names       = ["${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"]

  subject {
    common_name = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"
  }
}

resource "acme_certificate" "certificate" {
  account_key_pem         = acme_registration.reg.account_key_pem
  certificate_request_pem = tls_cert_request.req.cert_request_pem

  dns_challenge {
    provider = "route53"
    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.my_aws_dns_zone.id
      AWS_REGION         = var.aws_region
    }
  }
}

resource "aws_acm_certificate" "acm_cert" {
  private_key       = tls_private_key.cert_key.private_key_pem
  certificate_body  = acme_certificate.certificate.certificate_pem
  certificate_chain = acme_certificate.certificate.issuer_pem

  tags = {
    Name        = "lets-encrypt-cert"
    Environment = "production"
  }
}

resource "aws_s3_object" "cert_body" {
  bucket       = aws_s3_bucket.tfe_bucket["tfe-shared-files"].id
  key          = "certificate.pem"
  content      = acme_certificate.certificate.certificate_pem
  acl          = "private"
  content_type = "application/x-pem-file"
  depends_on   = [aws_s3_bucket.tfe_bucket]
}

resource "aws_s3_object" "private_key" {
  bucket       = aws_s3_bucket.tfe_bucket["tfe-shared-files"].id
  key          = "private.key"
  content      = tls_private_key.cert_key.private_key_pem
  acl          = "private"
  content_type = "application/x-pem-file"
  depends_on   = [aws_s3_bucket.tfe_bucket]
}

resource "aws_s3_object" "cert_chain" {
  bucket       = aws_s3_bucket.tfe_bucket["tfe-shared-files"].id
  key          = "chain.pem"
  content      = acme_certificate.certificate.issuer_pem
  acl          = "private"
  content_type = "application/x-pem-file"
  depends_on   = [aws_s3_bucket.tfe_bucket]
}

