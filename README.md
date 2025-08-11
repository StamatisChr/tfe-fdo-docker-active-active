# install-TFE-with-docker

## What is this guide about?

This guide is to have Terraform Enterprise running with Docker.

## Prerequisites 

- Account on AWS Cloud

- AWS IAM user with permissions to use AWS EC2, RDS, S3, IAM, Route53 and ElastiCache services

- A DNS zone hosted on AWS Route53

- Terraform Enterprise FDO license

- Git installed and configured on your computer

- Terraform installed on your computer

## Create the AWS resources and start TFE

Export your AWS access key and secret access key as environment variables:
```
export AWS_ACCESS_KEY_ID=<your_access_key_id>
```

```
export AWS_SECRET_ACCESS_KEY=<your_secret_key>
```


Clone the repository to your computer.

Open your cli and run:
```
git clone git@github.com:StamatisChr/tfe-fdo-docker-active-active.git
```


When the repository cloning is finished, change directory to the repo’s terraform directory:
```
cd tfe-fdo-docker-active-active/terraform
```

Here you need to create a `variables.auto.tfvars` file with your specifications. Use the example tfvars file.

Rename the example file:
```
cp variables.auto.tfvars.example variables.auto.tfvars
```
Edit the file:
```
vim variables.auto.tfvars
```

```
# example tfvars file
# do not change the variable names on the left column
# replace only the values in the "< >" placeholders

aws_region                    = "<aws_region>"             # Set here your desired AWS region, example: eu-west-1
hosted_zone_name              = "<dns_zone_name>"          # your AWS route53 DNS zone name
tfe_license                   = "<tfe_license_string>"     # TFE license string
tfe_encryption_password       = "<type_a_password>"        # TFE encryption password
tfe_version_image             = "<tfe_version>"            # desired TFE version, example: v202410-1
tfe_database_password         = "<type_a_password>"        # The password for the external TFE database
```

To populate the file according to the file comments and save.

Initialize terraform, run:
```
terraform init
```

Create the resources with terraform, run:
```
terraform apply
```
review the terraform plan.

Type yes when prompted with:
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```
Wait until you see the apply completed message and the output values. 

Example:
```
Apply complete! Resources: 38 added, 0 changed, 0 destroyed.

Wait about 10-15 minutes for Terraform Enterprise to initialize.

Visit the official documentation to learn more about Terraform Enterprise application administration:
https://developer.hashicorp.com/terraform/enterprise/application-administration/general

## Clean up

To delete all the resources, run:
```
terraform destroy
```
type yes when prompted.

Wait for the resources deletion. It can take 20 minutes or more.

Done.