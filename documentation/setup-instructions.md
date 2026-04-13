**Setup Instructions for CI/CD Pipeline with Git, Jenkins, and Kubernetes**

** Overview**

This document explains how to configure and run the CI/CD pipeline defined in the Jenkinsfile.

The pipeline automates:

-Building Docker images from a Git repository

-Scanning images for vulnerabilities

-Deploying them to Kubernetes clusters (dev, staging, prod)

-Validating deployments and cleaning up resources


**Prerequisites**

Jenkins

-Installed Jenkins server (controller + agent with Docker installed)

Required plugins:

-Pipeline (Declarative Pipeline support)

-Git (SCM integration)

-Credentials Binding (secure secrets injection)

-GitHub Integration (for webhooks/triggers)

Docker

-Docker installed on Jenkins agent

-Access to a Docker registry (e.g., Docker Hub, ECR, GCR)

Kubernetes

-Three clusters: dev, staging, prod

-Exported kubeconfig files for each cluster

-kubectl installed on Jenkins agent

GitHub Repository Contains:

-Application source code

-Dockerfile

-Kubernetes manifests (deployment.yaml, service.yaml)

-Jenkinsfile at repo root

-documentation/ folder with setup guides


🔑 **Jenkins Credentials Setup**
Create the following credentials in Jenkins:

-GitHub Access

ID: github-creds

Type: Username/Password or Personal Access Token (PAT)

Example: GitHub username + PAT

-Docker Registry

ID: docker-cred

Type: Username/Password

Example: Docker Hub credentials

-Docker Image Name

ID: docker-image-name

Type: Secret Text

Example: spring-boot-web

-Docker Registry URL

ID: docker-registry-url

Type: Secret Text

Example: docker.io/username

-Kubeconfig (dev)

ID: kubeconfig-dev

Type: File

Example: Upload dev kubeconfig

-Kubeconfig (staging)

ID: kubeconfig-staging

Type: File

Example: Upload staging kubeconfig

-Kubeconfig (prod)

ID: kubeconfig-prod

Type: File

Example: Upload prod kubeconfig


🗂 **Git Repository Configuration**

1. Create/Use a GitHub repository  

Example: https://github.com/saumyasingh9/Jenkins-Git-Kubernetes-CI-CD-pipeline.git

2. Add files

Code
.
├── Jenkinsfile
├── Dockerfile
├── kubernetes/
│   ├── dev/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── staging/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── prod/
│       ├── deployment.yaml
│       └── service.yaml
└── documentation/
    ├── setup-instructions.md
    └── pipeline-explained.md

3. Configure GitHub webhook

-Go to Settings → Webhooks → Add webhook

-Payload URL: http://<jenkins-server>/github-webhook/

-Content type: application/json

-Trigger: Push events

-This ensures Jenkins triggers automatically on commits.


☸** Kubernetes Cluster Integration**

1. Export kubeconfig files 

From each cluster (dev, staging, prod):

bash
kubectl config view --raw > kubeconfig-dev
kubectl config view --raw > kubeconfig-staging
kubectl config view --raw > kubeconfig-prod

2. Upload kubeconfigs to Jenkins

-Go to Manage Jenkins → Credentials → Global → Add Credentials

-Type: File

-IDs: kubeconfig-dev, kubeconfig-staging, kubeconfig-prod

3. Pipeline reference  

The Jenkinsfile dynamically injects the correct kubeconfig based on the ENVIRONMENT 

withCredentials([file(credentialsId: "kubeconfig-${params.ENVIRONMENT}", variable: 'KUBECONFIG')]) {
    sh "kubectl apply -f deployment-temp.yaml"
}

4. Verify connectivity  

Run inside Jenkins agent:

kubectl --kubeconfig=$KUBECONFIG get nodes

You should see cluster nodes listed here.


⚙️ **Pipeline Parameters**

-REPO_URL → Git repository URL

-BRANCH → Git branch to build from

-ENVIRONMENT → Deployment environment (dev, staging, prod)

-DEPLOYMENT_NAME → Kubernetes deployment name (must match metadata.name in manifest)


⚙️**Setup Steps**

1. Clone repository into Jenkins pipeline job.

2. Configure credentials in Jenkins as described above.

3. Run pipeline (auto-triggered on GitHub push or manually).

4. Pipeline executes stages:

-Checkout → Pulls code from GitHub

-Build & Push → Builds Docker image and pushes to registry

-Security Scan → Runs Trivy scan, fails on HIGH/CRITICAL vulnerabilities

-Deploy → Applies manifests to Kubernetes cluster

-Validation → Lists pods, services, deployments

-Cleanup → Removes dangling Docker images


🔍 **Verification**

After pipeline run, check deployment status:

bash
kubectl get pods
kubectl get svc
kubectl get deployments
kubectl rollout status deployment/<DEPLOYMENT_NAME>


🔒 **Security Notes**

-Store all secrets in Jenkins credentials, never in code.

-Use kubeconfig file credentials for cluster access.

-Trivy scan enforces security by failing pipeline on HIGH/CRITICAL vulnerabilities.

-Use Git branches (dev, staging, prod) to isolate environments.

