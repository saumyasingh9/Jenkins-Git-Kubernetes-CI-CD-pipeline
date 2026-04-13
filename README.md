# Jenkins CI/CD Pipeline

## Overview
This project demonstrates a Jenkins Declarative Pipeline that automates:
- Checkout from GitHub
- Docker image build and push
- Security scan with Trivy
- Deployment to Kubernetes (dev, staging, prod)
- Validation and cleanup

## Prerequisites
- Jenkins with plugins: Pipeline, Git, GitHub Integration, Credentials Binding, Docker Pipeline, Kubernetes CLI
- Docker installed on Jenkins agent
- Kubernetes clusters accessible via kubeconfig files
- GitHub repo with source code, Dockerfile, and Kubernetes manifests

## Credentials
Configure Jenkins credentials for:
- GitHub access
- Docker registry login
- Docker image name and registry URL
- Kubeconfig files for dev, staging, prod

## Workflow
1. Checkout code  
2. Docker login  
3. Build and push image  
4. Run Trivy security scan  
5. Deploy to Kubernetes  
6. Validate resources  
7. Cleanup local images  

## Security Notes
- Secrets are stored in Jenkins credentials, not in code  
- Trivy scan fails pipeline on HIGH/CRITICAL vulnerabilities  
- Separate branches isolate environments  

## Conclusion
This pipeline delivers a secure, reproducible CI/CD flow from GitHub to Kubernetes.
