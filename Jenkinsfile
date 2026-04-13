pipeline {
    agent any

    parameters {
        string(name: 'REPO_URL', defaultValue: 'https://github.com/saumyasingh9/Jenkins-Git-Kubernetes-CI-CD-pipeline.git', description: 'Git repository to build from')
        string(name: 'BRANCH', defaultValue: 'main', description: 'Git Branch to build from')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Deployment Environment')
        string(name: 'DEPLOYMENT_NAME', defaultValue: 'jenkins-k8s-app', description: 'Kubernetes Deployment name (must match metadata.name in manifest)')
    }

    environment {
        // IMAGE_NAME and REGISTRY must be stored as Secret Text credentials in Jenkins.
        IMAGE_NAME      = credentials('docker-image-name')   // Docker image name (Secret Text)
        REGISTRY        = credentials('docker-registry-url') // Docker registry URL (Secret Text)
        DEPLOYMENT_NAME = "${params.DEPLOYMENT_NAME}"        // Parameterized deployment name
        GIT_CREDENTIALS = 'github-creds'                     // GitHub credentials ID
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: "${params.BRANCH}",
                    credentialsId: "${GIT_CREDENTIALS}",
                    url: "${params.REPO_URL}"
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                    echo ${DOCKER_PASS} | docker login ${REGISTRY} -u ${DOCKER_USER} --password-stdin
                    """
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker push ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Security Scan') {
            steps {
                sh """
                docker run --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                aquasec/trivy image \
                --severity HIGH,CRITICAL \
                --exit-code 1 \
                ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([file(credentialsId: "kubeconfig-${params.ENVIRONMENT}", variable: 'KUBECONFIG')]) {
                        sh """
                        # Work on a temporary copy so the original manifest stays reusable
                        cp kubernetes/${params.ENVIRONMENT}/deployment.yaml deployment-temp.yaml
                        sed -i 's|IMAGE_NAME|${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}|g' deployment-temp.yaml

                        kubectl apply -f deployment-temp.yaml
                        kubectl apply -f kubernetes/${params.ENVIRONMENT}/service.yaml

                        kubectl rollout status deployment/${DEPLOYMENT_NAME}
                        rm deployment-temp.yaml
                        """
                    }
                }
            }
        }

        stage('Validation') {
            steps {
                script {
                    withCredentials([file(credentialsId: "kubeconfig-${params.ENVIRONMENT}", variable: 'KUBECONFIG')]) {
                        sh '''
                        echo "Validating Kubernetes resources..."
                        kubectl get pods
                        kubectl get svc
                        kubectl get deployments
                        '''
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // Remove dangling images locally
                    sh "docker image prune -f"
                }
            }
        }
    }

    post {
        success {
            echo "Build, security scan, deployment, validation, and cleanup successful."
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
        always {
            echo "Pipeline run completed. Check above logs for details."
        }
    }
}
