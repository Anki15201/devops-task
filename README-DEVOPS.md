# DevOps Task: CI/CD Pipeline for Node.js App

## Overview
This repository demonstrates a simple CI/CD pipeline for a sample Node.js application using GitHub for version control, Jenkins for automation, AWS for infrastructure (via Terraform IaC), and best DevOps practices. The pipeline automates building, testing, Dockerizing, pushing to ECR, and deploying to EC2.

## Architecture Diagram
![Architecture Diagram](deployment-proof/Architecture.png)

(Description: The diagram shows GitHub webhook triggering Jenkins on EC2. 
                Jenkins pipeline: Build (npm install/test) → Docker build → Push to ECR → Deploy toEC2. 
                Infrastructure: VPC, Security Groups, EC2 (with Jenkins/Docker/Node.js installed via user_data script), 
                ECR. 
                Monitoring via CloudWatch.)

## Setup Instructions
1. **Prerequisites**:
   - AWS Account with IAM user (permissions for EC2, ECR, ECS, VPC, CloudWatch).
   - GitHub Account.
   - Terraform installed locally.
   - Docker installed locally (for testing).

2. **Clone and Set Up Repository**:
   - Fork/clone the sample Node.js app: `git clone https://github.com/SwayattDrishtigochar/devops-task app/`.
   - Create branches: `git checkout -b dev` (for development), `git checkout main` (for production).
   - Push to your GitHub repo: `git remote add origin <your-repo-url>` and `git push -u origin main`.

3. **Infrastructure Setup (Terraform IaC)**:
   - Navigate to `/terraform/`.
   - Update `variables.tf` with your AWS region, VPC CIDR, etc.
   - Run: `terraform init`, `terraform plan`, `terraform apply`.
   - This creates:
     - VPC and subnets.
     - Security groups (allow HTTP/HTTPS, SSH, Jenkins port 8080, Application port 3000).
     - EC2 instance (Ubuntu Linux) with user_data script (`setup.sh`) to install: Docker, AWS CLI, Java JDK 17, Jenkins, Node.js.
     - ECR repository for Docker images.
   - Note: `setup.sh` runs on EC2 boot, automating installations and starting Jenkins/Docker services.

4. **Jenkins Setup**:
   - SSH into EC2 (use public IP from Terraform output).
   - Access Jenkins at `http://13.201.133.80:8080/`.
   - Unlock Jenkins with initial admin password (from EC2 logs: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`).
   - Install plugins: GitHub Integration, Docker Pipeline, AWS Steps.
   - Create a new pipeline job using the `Jenkinsfile` in this repo.
   - Set up GitHub webhook: In GitHub repo settings → Webhooks → Add webhook (payload URL: `http://13.201.133.80:8080/github-webhook/`, content type: application/json, events: Push).

5. **Pipeline Flow Explanation**:
   - **Trigger**: GitHub push (e.g., to `main` branch) triggers webhook.
   - **Stages** (defined in `Jenkinsfile`):
     - **Build**: `npm install` and run tests (`npm test`).
     - **Dockerize**: Build Docker image using `Dockerfile` (Node.js app on port 3000).
     - **Push to Registry**: Tag and push image to AWS ECR (using AWS credentials in Jenkins).
     - **Deploy**: Deploy container to AWS EC2 (pull from ECR and run).
   - The pipeline ensures automation: Code changes → Auto-build/deploy.

6. **Monitoring & Logging**:
   - Use AWS CloudWatch for EC2/Jenkins/ECS metrics (CPU, memory) and logs.
   - View logs/metrics:
     - Go to AWS Console → CloudWatch → Logs → Log groups (e.g., `/ecs/your-task` for ECS, `/ec2/jenkins` for Jenkins logs).
     - Metrics: CloudWatch → Metrics → Search for EC2/ECS namespaces.
     - Enable agent on EC2 for detailed logs: Already configured in `setup.sh`.

7. **Deployment Proof**:
   - See `./deployment-proof/` folder for screenshots:
     - Jenkins pipeline success.
     - ECS deployment running.
     - architecture
     - ECR image
     - terraform output
     - webhook setup
   - Public URL: `http://13.201.133.80:3000/` 

## Short Write-up
### Tools & Services Used
- **Version Control**: GitHub (branching: main, webhooks).
- **CI/CD**: Jenkins (pipeline with stages: build, dockerize, push, deploy).
- **IaC**: Terraform (for VPC, SG, EC2, ECR).
- **Containerization**: Docker (Dockerfile), AWS ECR (registry).
- **Deployment**: AWS EC2 (hosts Jenkins).
- **Monitoring**: AWS CloudWatch (logs/metrics).
- **Other**: AWS CLI (in setup.sh), Node.js (app runtime), Java JDK 17 (for Jenkins).

### Challenges Faced & Solutions
- **Automating EC2 Setup**: Manually installing tools was error-prone; solved by creating `setup.sh` as user_data in Terraform – it installs Docker, AWS CLI, JDK, Jenkins, Node.js, and starts services automatically.
- **Jenkins-ECR Integration**: Authentication issues; solved by adding AWS credentials to Jenkins and using `aws ecr get-login-password` in pipeline.
- **Security**: Open ports risked exposure; used security groups to restrict to specific IPs/ports.
- **Testing Pipeline**: Webhook failures; fixed by ensuring EC2 security group allows GitHub IP ranges.

### Possible Improvements If Given More Time
- Add unit/integration tests in the app and fail pipeline on test errors.
- Implement blue-green deployments in ECS for zero-downtime.
- Use AWS CodePipeline instead of Jenkins for native AWS integration.
- Add auto-scaling to ECS based on CloudWatch alarms.
- Integrate Slack notifications for pipeline failures.
- Use EKS for deployment