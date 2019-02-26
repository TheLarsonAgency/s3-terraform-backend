provider "aws" {}

variable "site" {
  type = "string"
  description = "A unique site name for allocation of resources"
}

# create an S3 bucket to store the state file in
resource "aws_s3_bucket" "terraform-state-storage-s3" {
  bucket = "${var.site}-terraform-remote-state-storage-s3"
 
  versioning {
    enabled = true
  }
 
  lifecycle {
    prevent_destroy = true
  }
 
  tags {
    Name = "S3 Remote Terraform State Store"
  }      
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "${var.site}-terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
 
  tags {
    Name = "DynamoDB Terraform State Lock Table"
  }

  depends_on = ["aws_s3_bucket.terraform-state-storage-s3"]
}

# create a KMS key for state encryption
resource "aws_kms_key" "terraform-kms" {
  description = "terraform KMS key"
}
