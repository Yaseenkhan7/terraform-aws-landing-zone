# This is the root configuration for the 'staging' environment.

terraform {
  # Configure the S3 backend for remote state management.
  # This should be created manually or via a separate bootstrap process.
  backend "s3" {
    bucket         = "yaseenkhan7-terraform-state-staging"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- Data Sources to get information about the environment ---

data "aws_caller_identity" "current" {}

# --- Module Definitions ---

# Create the foundational organization structure (only run from a management account).
# In a real scenario, this might be in its own separate 'global' environment.
module "organizations" {
  source = "../../modules/organizations"

  new_account_name  = "Staging-Workload-Account"
  new_account_email = "yaseenkhan7-staging-aws@example.com" # Use a unique email alias
}

# Example of deploying an application into the staging environment.
# Note: In a real multi-account setup, you would use provider aliases or assume roles
# to provision resources in the correct workload account.
module "my_staging_app" {
  source = "../../modules/iaas-app-module"

  # These would typically come from a dedicated networking module.
  # For this example, we are using placeholder values.
  vpc_id             = "vpc-0123456789abcdef0"
  public_subnet_ids  = ["subnet-01234567", "subnet-0abcdef1"]
  private_subnet_ids = ["subnet-0fedcba9", "subnet-07654321"]
  ami_id             = "ami-0c55b159cbfafe1f0" # Example Amazon Linux 2 AMI

  application_name = "my-staging-app"
  instance_type    = "t3.small"
  min_instances    = 1
  max_instances    = 3
}

output "application_endpoint" {
  description = "The DNS endpoint for the staging application."
  value       = module.my_staging_app.alb_dns_name
}
