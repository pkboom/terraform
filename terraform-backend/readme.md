# Usage

Run `terraform init` to

1. download the provider code
1. configure your Terraform backend

Run terraform apply to deploy.

# Use Backend

1. Write Terraform code to create the S3 bucket and DynamoDB table, and deploy that code with a local backend.
1. Go back to the Terraform code, add a remote backend configuration to it to use the newly created S3 bucket and DynamoDB table, and run terraform init to copy your local state to S3.

# Delete the S3 bucket and DynamoDB table

1. Remove the backend configuration
1. Rerun `terraform init` to copy the Terraform state back to your local disk.
1. Run `terraform destroy` to delete the S3 bucket and DynamoDB table.

https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa#0054
