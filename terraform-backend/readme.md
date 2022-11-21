# Usage

Run `terraform init` to

1. download the provider code
1. configure your Terraform backend

Run terraform apply to deploy.

```sh
terraform apply -var-file variables.tfvars
```

# Use Backend

1. Write Terraform code to create the S3 bucket and DynamoDB table, and deploy that code with a local backend.
1. Go back to the Terraform code, add a remote backend configuration to it to use the newly created S3 bucket and DynamoDB table, and run terraform init to copy your local state to S3.

# Delete the S3 bucket and DynamoDB table

1. Remove the backend configuration
1. Rerun `terraform init` to copy the Terraform state back to your local disk.
1. Run `terraform destroy` to delete the S3 bucket and DynamoDB table.

https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa#0054

# Use partial configuration for backend

Create backend.hcl and add it when running `terraform init`. Only the `key` parameter remains in the Terraform code

```
terraform {
  backend "s3" {
    key = "example/terraform.tfstate"
  }
}
```

```sh
terraform init -backend-config=backend.hcl
```

# Import resources

If you are encountering a BucketAlreadyOwnedByYou error with the aws_s3_bucket resource, you will either need to import the existing S3 Bucket configuration into Terraform or use the aws_s3_bucket data source instead of the aws_s3_bucket resource.

```sh
data "aws_s3_bucket" "mybucket" {
  bucket = "existing-bucket-name"
}

output "my_bucket_name" {
  value = "${data.aws_s3_bucket.mybucket.bucket}"
}
```

```sh
terraform import aws_s3_bucket.terraform_state terraform-state-keunbae
terraform import aws_dynamodb_table.terraform_locks terraform-locks-keunbae
```

https://github.com/hashicorp/terraform-provider-aws/issues/423#issuecomment-510072042

# BucketNotEmpty

When trying to delete an bucket that is not empty, you will get an error message `BucketNotEmpty`.

Apply `force_destroy = true` before deleting a bucket.

```sh
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-keunbae"
  force_destroy = true
  ...
}
```

```sh
terraform apply
terraform destroy
# or
terraform plan -destroy -target=aws_s3_bucket.name
```

https://dev.to/the_cozma/terraform-handling-the-deletion-of-a-non-empty-aws-s3-bucket-3jg3
