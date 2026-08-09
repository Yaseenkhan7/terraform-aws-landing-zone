
variable "organization_feature_set" {
  description = "The feature set for the organization (ALL or CONSOLIDATED_BILLING)."
  type        = string
  default     = "ALL"
}

variable "workload_ou_name" {
  description = "The name for the Workloads Organizational Unit."
  type        = string
  default     = "Workloads"
}

variable "new_account_email" {
  description = "The email for the new AWS account. MUST be unique."
  type        = string
}

variable "new_account_name" {
  description = "The name for the new AWS account."
  type        = string
}


resource "aws_organizations_organization" "main" {
  feature_set = var.organization_feature_set
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = var.workload_ou_name
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_account" "new_account" {
  name      = var.new_account_name
  email     = var.new_account_email
  parent_id = aws_organizations_organizational_unit.workloads.id

 
  role_name = "OrganizationAccountAccessRole"
}

resource "aws_organizations_policy" "deny_unapproved_regions" {
  name = "DenyUnapprovedRegions"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyRegionsOutsideNorthAmerica"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = ["us-east-1", "us-west-2", "ca-central-1"]
          }
        }
      },
    ]
  })
}

resource "aws_organizations_policy_attachment" "attach_region_policy" {
  policy_id = aws_organizations_policy.deny_unapproved_regions.id
  target_id = aws_organizations_organizational_unit.workloads.id
}


output "organization_id" {
  value = aws_organizations_organization.main.id
}

output "workloads_ou_id" {
  value = aws_organizations_organizational_unit.workloads.id
}

output "new_account_id" {
  value = aws_organizations_account.new_account.id
}
