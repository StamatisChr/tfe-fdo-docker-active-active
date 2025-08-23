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

# Create the AWS resources and start TFE

## Set AWS credentials

Export your AWS access key and secret access key as environment variables:
```
export AWS_ACCESS_KEY_ID=<your_access_key_id>
```

```
export AWS_SECRET_ACCESS_KEY=<your_secret_key>
```


## Clone the repository to your computer

Open your cli and run:
```
git clone git@github.com:StamatisChr/tfe-fdo-docker-active-active.git
```


When the repository cloning is finished, change directory to the repo’s terraform directory:
```
cd tfe-fdo-docker-active-active
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
# replace only the values in the " " placeholders

hosted_zone_name              = "<dns_zone_name>"          # your AWS route53 DNS zone name
tfe_version_image             = "<tfe_version>"            # desired TFE version, example: v202410-1
tfe_license                   = "<tfe_license_string>"     # TFE license string
```

To populate the file according to the file comments and save.

The default AWS region the resources will be created is `eu-west-1`, if you need to change the AWS region and the default passwords, you can edit them in `variables.tf` or by adding an entry in the `variables.auto.tfvars` with the variable name and the value you want.

## Create TFE infrastructure

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
Apply complete! Resources: 40 added, 0 changed, 0 destroyed.
```

## Wait for TFE resources creation

change directory:
```
cd 00-wait-tfe-start
```

run the terraform configuration:
```
terraform init
```

```
terraform apply --auto-approve
```

This can take 15-20 minutes.
Wait until the run is completed.

## Create initial admin user

change directory:
```
cd ../01-create-initial-admin
```

run the terraform configuration:
```
terraform init
```

```
terraform apply --auto-approve
```
When the run is finished continue to the next step.

## Create a TFE organization and workspace

change directory:
```
cd ../02-tfe-org-ws
```

run the terraform configuration:
```
terraform init
```

```
terraform apply --auto-approve
```

When the run is finished use the output values to login to TFE.
- Copy the `terraform_login` output command, paste it on your CLI and run it.

Type `yes` when prompted.

You will be redirected to TFE login page.
  
- Use the `tfe_admin_user` and `tfe_admin_password` as username and password to login to TFE.

- Create a token and copy it.

- Back to your CLI paste the token to the prompt

Continue to the next step.

## Run terraform configuration on TFE with CLI-driven remote run workflow

change directory:
```
cd ../03-example-cli-driven-ws
```

run the terraform configuration:
```
terraform init
```
```
terraform apply --auto-approve 
```

Example output:
```
Preparing the remote apply...

To view this run in a browser, visit:
https://unified-prawn.stamatios-chrysinas.sbx.hashidemos.io/app/example-org/example-workspace/runs/run-5xDKMBDEf6v1evj1
```

You can use the `To view this run in a browser, visit:` URL to see this run on TFE.

## Destroy the terraform run resources

Run:
```
terraform apply --auto-approve
```

## Clean up

To delete all the infrastructure resources, run:

```
cd ..
```

Now in the `tfe-fdo-docker-active-active` run:

```
terraform destroy
```
type yes when prompted.

Wait for the resources deletion. It can take 20 minutes or more.

Done.
