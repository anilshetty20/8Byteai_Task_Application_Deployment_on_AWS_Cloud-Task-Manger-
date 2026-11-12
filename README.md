# AWS DevOps Project – Task Manager Application Deployment

## 1. Project Overview

This project demonstrates the deployment of a containerized Task Manager application on AWS using Infrastructure as Code (IaC), automated CI/CD, secure AWS access and centralized monitoring and logging.

The application consists of:

- **Frontend:** React application built with Vite and served using Nginx.
- **Backend:** Python FastAPI application.
- **Database:** Amazon RDS PostgreSQL.

The infrastructure is provisioned using Terraform, while GitHub Actions automates Docker image building, publishing and application deployment.

The project follows AWS security best practices by hosting application and database resources in private subnets, using IAM roles for authentication, AWS Secrets Manager for database credentials and AWS Systems Manager for secure instance management.

## 2. Architecture

### High-Level Architecture

```text
                         Internet
                            |
                            |
                 Application Load Balancer
                    (Public Subnets)
                            |
                            |
                    Private EC2 Instance
                     (Docker Compose)
                            |
                  ----------------------
                  |                    |
             Frontend              Backend
             React/Nginx           FastAPI
                  |                    |
                  |                    |
                  ----------------------
                            |
                            |
                    Amazon RDS
                      PostgreSQL
                    (Private Subnets)


                  CI/CD Architecture

                  Developer Push
                        |
                        v
                   GitHub Repository
                        |
                        v
                  GitHub Actions
                        |
                  AWS OIDC Authentication
                        |
                        v
                  Docker Image Build
                        |
                        v
                  Amazon ECR
                 /           \
           Backend Image   Frontend Image
                 \           /
                        |
                        v
                AWS Systems Manager
                        |
                        v
                Private EC2 Instance
                        |
                        v
                 Docker Deployment


                Monitoring Architecture

                  EC2 Instance
                        |
               ---------------------
               |                   |
          CloudWatch Agent     Docker awslogs
               |                   |
               |             Backend / Frontend
               |                   |
               -----------+--------
                          |
                          v
                  Amazon CloudWatch
                  Metrics and Logs
```

### AWS Infrastructure Components

| Component | Description |
|---|---|
| Amazon VPC | Custom virtual private cloud |
| Public Subnets | Host the internet-facing ALB |
| Private Application Subnet | Hosts the EC2 application instance |
| Private Database Subnets | Host the RDS PostgreSQL database |
| Internet Gateway | Provides internet connectivity to public resources |
| NAT Gateway | Enables outbound connectivity from private resources |
| Application Load Balancer | Routes incoming application traffic |
| Amazon EC2 | Hosts the Dockerized application |
| Amazon RDS | Managed PostgreSQL database |
| Amazon ECR | Stores private Docker images |
| AWS Systems Manager | Provides secure remote instance management |
| AWS Secrets Manager | Stores database credentials |
| Amazon CloudWatch | Collects infrastructure metrics and application logs |

## 3. Technology Stack

### Cloud and Infrastructure
- AWS
- Terraform
- Amazon VPC
- Amazon EC2
- Application Load Balancer
- Amazon RDS PostgreSQL
- Amazon ECR
- AWS Systems Manager
- AWS IAM
- AWS Secrets Manager
- Amazon CloudWatch

### Application and Containerization
- React
- Vite
- Python
- FastAPI
- PostgreSQL
- Docker
- Docker Compose
- Nginx

### CI/CD
- GitHub
- GitHub Actions
- GitHub OpenID Connect (OIDC)
- AWS IAM
- Amazon ECR

## 4. Repository Structure

The repository is organized into application source code, infrastructure configuration and CI/CD workflow files.

```text
8Byteai_Task_Application_Deployment_on_AWS_Cloud-Task-Manger/
│
├── backend/
│   ├── app/
│   ├── Dockerfile
│   └── requirements.txt
│
├── frontend/
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   └── nginx.conf
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── other Terraform configuration files
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── docker-compose.prod.yml
├── README.md
└── .gitignore
```

*Note: Adjust the Terraform directory and filenames above to match the actual repository structure.*

## 5. Infrastructure Provisioning Using Terraform

Terraform is used to provision the AWS infrastructure.

### Infrastructure Created

1. Custom VPC.
2. Public and private subnets across two Availability Zones.
3. Internet Gateway.
4. NAT Gateway and private route tables.
5. Security groups for ALB, EC2 and RDS.
6. EC2 instance with an IAM instance profile.
7. Application Load Balancer and target group.
8. Amazon RDS PostgreSQL instance.
9. Secrets Manager integration for database credentials.

### Terraform Configuration

The Terraform configuration uses variables for configurable infrastructure parameters, such as:

- AWS region.
- VPC CIDR.
- Public subnet CIDRs.
- Private application subnet CIDRs.
- Private database subnet CIDRs.
- EC2 instance configuration.
- RDS instance configuration.
- Database name and related settings.

### Terraform Deployment

Install Terraform and configure AWS authentication before provisioning.

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the infrastructure changes:

```bash
terraform plan
```

Provision the infrastructure:

```bash
terraform apply
```

Review the Terraform outputs:

```bash
terraform output
```

To destroy the infrastructure when it is no longer needed:

```bash
terraform destroy
```

**Important:** Review all resources and costs before running `terraform destroy`. This operation can delete the application infrastructure and database.

### Terraform State Management

Terraform state tracks the infrastructure resources managed by Terraform.

For collaborative or production environments, a remote backend using Amazon S3 with state locking should be configured.

The backend configuration should be verified in the Terraform project before claiming remote state management is implemented.

## 6. Application Deployment Using Docker

The application is containerized using Docker.

### Backend

The FastAPI backend is packaged using a Python Docker image and runs using Uvicorn.

### Frontend

The React application is built using a multi-stage Docker build.

Nginx serves the production frontend and proxies API requests to the backend container.

### Docker Compose

Docker Compose manages both application services:

- Backend container.
- Frontend container.

The backend connects to the PostgreSQL database using the `DATABASE_URL` environment variable.

The application uses Docker health checks to verify backend availability.

The frontend is exposed through port 80 and receives external traffic through the Application Load Balancer.

## 7. CI/CD Pipeline Using GitHub Actions

GitHub Actions automates Docker image building, publishing and application deployment.

### Pipeline Workflow

The current workflow is triggered by:

- Pushes to the `main` branch.
- Manual execution using `workflow_dispatch`.

### Pipeline Steps

**Step 1 – Source Code Checkout**

GitHub Actions checks out the application source code.

**Step 2 – AWS Authentication**

GitHub Actions authenticates with AWS using OpenID Connect.

No long-lived AWS access keys are stored in the GitHub repository.

**Step 3 – Docker Image Build**

Separate Docker images are built for:

- Backend.
- Frontend.

**Step 4 – Push Images to Amazon ECR**

Images are tagged using the GitHub commit SHA and pushed to private ECR repositories.

Example repositories:

```text
task-manager-backend
task-manager-frontend
```

**Step 5 – Deployment Through AWS Systems Manager**

GitHub Actions triggers an AWS Systems Manager Run Command on the private EC2 instance.

The deployment script:

1. Authenticates Docker with Amazon ECR.
2. Pulls the newly built backend and frontend images.
3. Updates the production Docker Compose configuration.
4. Runs Docker Compose to recreate the application containers.
5. Removes unused Docker images.
6. Checks the deployment command status.

### GitHub Actions Workflow

The workflow is located at:

```text
.github/workflows/deploy.yml
```

### GitHub Repository Variables

Configure the following repository variables under:

GitHub → Settings → Secrets and variables → Actions → Variables.

| Variable | Description |
|---|---|
| `AWS_REGION` | AWS deployment region |
| `AWS_ROLE_ARN` | GitHub Actions IAM role ARN |
| `ECR_BACKEND_REPOSITORY` | Backend ECR repository |
| `ECR_FRONTEND_REPOSITORY` | Frontend ECR repository |
| `EC2_INSTANCE_ID` | Application EC2 instance ID |

### GitHub Repository Secrets

Configure sensitive values under the GitHub Actions Secrets section.

| Secret | Description |
|---|---|
| `AWS_ACCOUNT_ID` | AWS account ID |

### IAM and OIDC Security

A GitHub OIDC identity provider is configured in AWS IAM.

An IAM role is created with a trust relationship restricted to the specified GitHub repository and the `main` branch.

The role has permissions required for:

- ECR authentication and image publishing.
- AWS Systems Manager deployment.
- Deployment status checks.

The EC2 instance uses its own IAM instance role to access ECR and Systems Manager and publish CloudWatch logs.

## 8. Monitoring and Logging

Amazon CloudWatch is used to monitor infrastructure metrics and centralize application logs.

### Infrastructure Monitoring

The CloudWatch Agent is installed on the EC2 instance.

The custom CloudWatch namespace is:

```text
TaskManager/EC2
```

The following metrics are collected:

| Metric | Purpose |
|---|---|
| `mem_used_percent` | Memory utilization |
| `used_percent` | Disk utilization |
| `free` | Available disk space |
| `cpu_usage_user` | CPU usage by applications |
| `cpu_usage_system` | CPU usage by system processes |
| `cpu_usage_idle` | Idle CPU percentage |
| Disk I/O metrics | Disk read/write activity |

Metrics are collected at 60-second intervals.

### Centralized Application Logging

Docker's AWS Logs logging driver is configured for both application containers.

The following CloudWatch log groups are used:

| Log Group | Description |
|---|---|
| `/task-manager/backend` | FastAPI backend logs |
| `/task-manager/frontend` | Nginx frontend logs |
| `/task-manager/system` | Intended Ubuntu system log group; collection must be configured and verified |

The backend and frontend log groups are configured with seven-day retention.

The logging configuration is included in the GitHub Actions deployment script to ensure it remains present after future deployments.

### Monitoring Improvements

Additional monitoring enhancements include:

- Application request rate.
- Application error rate.
- API response latency.
- PostgreSQL database metrics.
- CloudWatch alarms.
- Consolidated infrastructure and application dashboards.

These should be added and verified as part of the extended monitoring implementation.

## 9. Security Considerations

Security was considered throughout the infrastructure and deployment process.

### Network Security

- The application EC2 instance is deployed in a private subnet.
- The RDS PostgreSQL database is deployed in private database subnets.
- The database is not publicly accessible.
- Security groups restrict communication between the ALB, application and database layers.
- The ALB provides the public entry point for the application.

### Secure Instance Access

AWS Systems Manager Session Manager is used to access the EC2 instance.

This avoids requiring SSH access from the public internet.

### IAM Security

IAM roles are used instead of hardcoded AWS access keys.

GitHub Actions uses OIDC authentication with a repository-restricted trust relationship.

### Secrets Management

AWS Secrets Manager stores the PostgreSQL application credentials.

The EC2 instance retrieves the credentials using its IAM instance role.

Database passwords are not committed to GitHub.

### Container Security

Docker images are stored in private Amazon ECR repositories.

The application is deployed using versioned image tags based on Git commit SHA values.

## 10. Backup and Recovery

Amazon RDS provides managed database backup capabilities.

The RDS automated backup retention period and point-in-time recovery settings should be configured and verified according to the required recovery objectives.

Database recovery should be tested before treating the backup strategy as production-ready.

## 11. Cost Optimization

The following cost-conscious decisions are used in this assignment:

- A single EC2 instance is used for application hosting.
- RDS is configured as Single-AZ for the assignment environment.
- Docker images are stored in private ECR repositories.
- CloudWatch application log retention is set to seven days.
- Instance sizing is selected based on the application's resource requirements.
- Unused Docker images are pruned after deployment.

### AWS Resources That May Incur Ongoing Charges

- EC2 instance.
- Application Load Balancer.
- NAT Gateway and associated data processing.
- RDS PostgreSQL.
- Amazon ECR storage.
- CloudWatch custom metrics and logs.
- Secrets Manager.

Review AWS Billing and Cost Explorer regularly to monitor expenditure.

## 12. Challenges Faced and Resolutions

### PostgreSQL Schema Permission Issue

**Problem:** The backend could connect to PostgreSQL but could not create database tables because the application user lacked schema permissions.

**Resolution:** Granted the required CONNECT, USAGE and CREATE privileges to the application database user.

### GitHub Actions OIDC Authentication

**Problem:** GitHub Actions could not assume the AWS IAM role.

**Resolution:** Corrected the IAM trust relationship to match the GitHub repository's immutable OIDC subject claim.

### Amazon ECR Push Failure

**Problem:** Docker image publishing failed with HTTP 403 Forbidden.

**Resolution:** Added the required ECR authentication, manifest and image upload permissions to the GitHub Actions IAM role.

### Deployment to Private EC2

**Problem:** The application instance was hosted in a private subnet and was not directly accessible from the public internet.

**Resolution:** Used AWS Systems Manager Run Command to deploy the application securely.

### Docker Compose Configuration Overwritten

**Problem:** Manual changes to the production Compose file were overwritten during automated deployments.

**Resolution:** Updated the embedded Docker Compose configuration in the GitHub Actions deployment workflow so that logging settings are preserved.

### Centralized Docker Logging

**Problem:** Docker initially stored application logs using its default `json-file` logging driver.

**Resolution:** Configured Docker's `awslogs` driver and verified that backend and frontend logs were successfully delivered to CloudWatch Logs.

## 13. Future Enhancements

The following improvements can extend the current implementation:

- Add automated unit and integration tests.
- Add pull-request validation workflows.
- Introduce dependency and container vulnerability scanning.
- Add a staging environment.
- Add manual production deployment approval.
- Configure automated deployment failure notifications.
- Configure CloudWatch alarms for critical infrastructure metrics.
- Collect Ubuntu system logs centrally.
- Implement application-level metrics for request rate, error rate and latency.
- Add PostgreSQL monitoring dashboards.
- Create separate infrastructure and application monitoring dashboards.
- Configure and test an RDS backup and recovery strategy.
- Configure Terraform remote state management and locking if not already enabled.
- Introduce HTTPS using AWS Certificate Manager.

## 14. Conclusion

This project demonstrates an end-to-end AWS DevOps implementation covering Infrastructure as Code, containerization, CI/CD automation, secure deployment and centralized monitoring.

Terraform is used to provision the AWS infrastructure, Docker packages the application, GitHub Actions automates deployment, Amazon ECR stores the application images, AWS Systems Manager enables secure deployment to private EC2 and Amazon CloudWatch provides infrastructure metrics and centralized application logging.

The implementation provides practical experience with AWS services, infrastructure automation, CI/CD security, database connectivity, deployment troubleshooting and observability.

## 15. Project Repository

**GitHub Repository:**

https://github.com/anilshetty20/8Byteai_Task_Application_Deployment_on_AWS_Cloud-Task-Manger-
