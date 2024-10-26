pipeline {
    agent any


    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/mohamedmshokry/sample-Flask-AKS.git', branch: 'main'
            }
        }

        stage('Install Azure CLI') {
            steps {
                script {
                    // Check if Azure CLI is installed
                    def azureInstalled = sh(script: 'az --version', returnStatus: true)
                    if (azureInstalled != 0) {
                        // Install Azure CLI if not installed
                        sh 'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash'
                    } else {
                        echo 'Azure CLI is already installed.'
                    }
                }
            }
        }

        stage('Install Docker') {
            steps {
                script {
                    // Check if Docker is installed
                    def dockerInstalled = sh(script: 'docker --version', returnStatus: true)
                    if (dockerInstalled != 0) {
                        // Install Docker if not installed
                        sh '''
                        sudo apt-get update
                        sudo apt-get install -y docker.io
                        sudo systemctl start docker
                        sudo systemctl enable docker
                        sudo usermod -aG docker $(whoami)
                        newgrp docker
                        '''
                    } else {
                        echo 'Docker is already installed.'
                    }
                }
            }
        }
        
        stage('Login to Azure') {
            steps {
                sh '''
                az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                az account set --subscription $AZURE_SUBSCRIPTION_ID
                '''
            }
        }

        stage('Login to ACR') {
            steps {
                script {
                    // Retrieve the ACR login server URL
                    def acrLoginServer = sh(script: "az acr show --resource-group ${ACR_RESOURCE_GROUP} --name ${ACR_NAME} --query 'loginServer' --output tsv", returnStdout: true).trim()

                    // Log in to ACR
                    sh "az acr login --name ${ACR_NAME}"

                    // Set the full image tag with the ACR login server
                    env.FULL_IMAGE_TAG = "${acrLoginServer}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    sh "docker build -t ${env.FULL_IMAGE_TAG} -f ${DOCKERFILE_PATH} ."
                    sh "docker push ${env.FULL_IMAGE_TAG}"
                }
            }
        }

        stage('Provision AKS with Terraform') {
            steps {
                script {
                    // Write the secret content to terraform.tfvars
                    withCredentials([file(credentialsId: 'a60aaf57-09e1-4bfd-a9a9-875fb508262a', variable: 'TFVARS_FILE')]) {
                        // Create a Terraform variable file
                        sh "cp ${TFVARS_FILE} terraform-aks-provisioning/terraform.tfvars"
                    }

                    // Check if Terraform is installed
                    def terraformInstalled = sh(script: 'terraform version', returnStatus: true)
                    if (terraformInstalled != 0) {
                        // Install Terraform if not installed
                        sh '''
                        sudo apt-get update
                        sudo apt-get install -y wget unzip
                        wget https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
                        unzip terraform_1.9.8_linux_amd64.zip
                        sudo mv terraform /usr/local/bin/
                        '''
                    } else {
                        echo 'Terraform is already installed.'
                    }

                    // Initialize and apply Terraform configuration
                    sh '''
                    cd terraform-aks-provisioning                               # Navigate to the directory with your Terraform files
                    terraform init                                              # Initialize Terraform
                    terraform plan -var-file=terraform.tfvars                   # Review the planned changes
                    terraform apply -var-file=terraform.tfvars -auto-approve    # Apply the changes
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up resources...'
        }
        success {
            echo 'Build and Push successful!'
        }
        failure {
            echo 'Build failed.'
        }
    }
}