# Automated AWS IaaS Landing Zone

**Author:** Yaseenkhan7  
**GitHub:** [https://github.com/Yaseenkhan7](https://github.com/Yaseenkhan7)

---

## 1. Executive Summary

This project demonstrates the architecture and end-to-end automation of a secure, scalable AWS Landing Zone using Infrastructure as Code (IaC). The goal was to create a foundational cloud environment that enforces security, governance, and networking best practices from day one.

Instead of deploying a single application, this project built a "cloud factory" a governed ecosystem where development teams can rapidly and safely provision their own infrastructure. The entire platform is codified with **Terraform**, making it repeatable, auditable, and version-controlled.

**Problem Solved:** Eliminated common challenges of uncontrolled cloud adoption, such as security vulnerabilities, inconsistent environments, and cost overruns, by establishing a centralized, automated, and secure foundation for all future AWS workloads.

---

## 2. Key Objectives

- **Centralized Governance:** Establish a multi-account structure with enforceable policies for security and compliance.
- **Scalable Networking:** Implement a hub-and-spoke network topology that can scale to hundreds of VPCs while centralizing traffic inspection.
- **Automated Security:** Enforce security controls and centralize logging and monitoring across all accounts from the moment of their creation.
- **Developer Self-Service:** Empower development teams by providing a safe environment and reusable modules to deploy their IaaS resources without manual intervention from a central cloud team.
- **Operational Excellence:** Ensure all infrastructure is managed through a GitOps-style CI/CD pipeline, providing auditability and reducing manual errors.

---

## 3. Core Technologies Used

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

## 4. Architectural Deep Dive

The Landing Zone is built on four core pillars: Governance, Networking, Security, and Developer Enablement.

### Pillar 1: Multi-Account Governance with AWS Organizations

A multi-account strategy provides strong isolation between environments. This is managed via Terraform, creating OUs for `Security`, `Infrastructure`, `Sandbox`, and `Workloads`, and applying Service Control Policies (SCPs) to enforce guardrails like restricting regions or preventing the disabling of security services.

### Pillar 2: Hub-and-Spoke Networking with Transit Gateway

A scalable network topology connects all environments securely. A central "Hub" VPC hosts the AWS Transit Gateway and network firewalls. All "Spoke" VPCs from workload accounts connect to this hub, centralizing traffic inspection and simplifying routing.

### Pillar 3: Centralized Security and Immutable Infrastructure

Security is integrated by default. CloudTrail and VPC Flow Logs are shipped to a central `LogArchive` account. GuardDuty and Security Hub are enabled across all accounts, aggregating findings in a central `Security` account. An automated pipeline using **Packer** builds hardened "Golden AMIs" to ensure a secure baseline for all EC2 instances.

### Pillar 4: Developer Enablement with a Self-Service IaaS Module

A reusable **Terraform module** was created to empower developers. This module acts as a "paved road," allowing teams to deploy a standard 3-tier IaaS application in a self-service manner. It abstracts away underlying complexities, ensuring speed and safety. Developers simply provide high-level inputs, and the module provisions a pre-configured, secure, and compliant application stack.

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
