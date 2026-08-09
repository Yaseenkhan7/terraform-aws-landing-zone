# Automated AWS IaaS Landing Zone

This project implements end-to-end automation of a secure, scalable AWS Landing Zone using Infrastructure as Code (IaC). it creates a cloud environment that enforces security, governance, and networking best practices.

Instead of deploying a single application, this project built a cloud factory, where development teams can rapidly and safely provision their own infrastructure. The entire platform is codified with **Terraform**, making it repeatable, auditable, and version-controlled.


---

## 2. Core Technologies Used

- **Infrastructure as Code:** Terraform
- **CI/CD & Automation:** GitHub Actions, Packer
- **Cloud Provider:** Amazon Web Services (AWS)
- **Core AWS Services:**
    - **Governance:** AWS Organizations (OUs, SCPs)
    - **Networking:** VPC, Transit Gateway, Route 53, AWS Network Firewall
    - **Security:** IAM, GuardDuty, Security Hub, CloudTrail
    - **Compute:** EC2, Auto Scaling Groups
    - **Storage:** S3

---

## Key Features

- **Multi-Account Governance with AWS Organizations**
  - Uses Terraform to manage separate OUs for `Security`, `Infrastructure`, `Sandbox`, and `Workloads`.
  - Uses Service Control Policies (SCPs) to enforce guardrails such as region restrictions and protection of security services.

- **Hub-and-Spoke Networking with Transit Gateway**
  - Uses a central VPC as the hub for connecting workload environments.
  - AWS Transit Gateway connects the spoke VPCs.
  - Network firewalls provide centralized traffic inspection and control.

- **Centralized Security and Immutable Infrastructure**
  - Centralizes CloudTrail and VPC Flow Logs in a dedicated `LogArchive` account.
  - Uses GuardDuty and Security Hub to monitor and aggregate security findings.
  - Uses Packer to build hardened Golden AMIs for EC2 instances.

- **Developer Self-Service with Terraform**
  - Provides a reusable Terraform module for deploying a standard three-tier application.
  - Developers provide high-level configuration values instead of managing the underlying infrastructure manually.
  - Standardizes application deployments while maintaining security and configuration requirements.

---

## 5. How to Use This Repository

This repository is structured into three main areas:

1.  **/environments:** Contains the root Terraform configurations for each environment (e.g., `prod`, `staging`). This is where modules are called and configured.
2.  **/modules:** Contains the reusable, modular Terraform code for each component of the Landing Zone (e.g., `organizations`, `networking`, `iaas-app-module`).
3.  **/packer:** Contains the Packer templates for building the Golden AMIs.

To deploy an environment, navigate to the appropriate directory and run the standard Terraform workflow:

```bash
# Navigate to the desired environment
cd environments/staging

# Initialize Terraform
terraform init

# Plan the changes
terraform plan

# Apply the changes
terraform apply
```
