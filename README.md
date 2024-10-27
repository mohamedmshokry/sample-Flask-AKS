# sample-Flask-AKS
Tutorial for dockerizing sample flask app and automate depoloyment to AKS using Jenkins and AzureDevOps

# Strategy for flask application deployment
Main steps followed to get sample flask application deployed on Azure AKs cluster in automated way:
* Package the application binaries to Docker image
* Create Helm chart for the flask application including ingress
* Create Azure AKS cluster, Virtual Network (vnet), Application gateway, and enabling Application Gatway Ingress Controller (AGIC) using terraform module
* Create Azure Container Registry (AKS) and integrate it with AKS
* Create pipelines for automating Flask application integration and Delivery (CICD ), AKS terraform provisioning and Helm chart deployment

## Main directoried in the repo:
* **app**: Contains Flask code
* **flask-app-chart**: contains flask application helm chart
* **terraform-aks-provisioning**: Contains terraform files and modules needed to Azure AKS, vnet and appgw infra provisioning
* **Jenkinsfiles**: Contains separate Jenkinsfiles for each pipeline created for the automation process

# Manaul validation steps for the flask application and the AKS
Below section contains manual steps for each milestone of the automated deployment of the flask application that is sutomated in latter section using Jenkins

## 1- Flask docker image creation
Clone the repo:
```
git clone https://github.com/mohamedmshokry/sample-Flask-AKS.git
```

Use Dockerfile included to build and test the validiy of the image and it can serve the app on its default port 5000 
```bash 
docker build -t sampleflask:0.1 . 

# Spine a container from the image to check if teh flask app is working exposing it to port 8000 on Docker host
docker run --name sampleflask -dp 8000:5000 sampleflask:0.1
```

Application should be accessed using the URL: http://localhost:8000/products and produces output like below

```bash
❯ curl -s http://localhost:8000/products | jq
[
  {
    "id": 1,
    "name": "Laptop"
  },
  {
    "id": 2,
    "name": "Smartphone"
  }
]
```

## 2- Create Helm chart for the flask application and validate it on minikube
As a prerequisite to create helm chart we need kubectl, helm and minikube or any other cluster available for testing the chart

Create a Helm chart directory structure:
```bash
helm create flask-app-chart
```
It will create the below directory structure:
```bash
❯ tree flask-app-chart
flask-app-chart
├── Chart.yaml
├── charts
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```
The default boilerplate code of the chart fits the flask app usecase as it contains:
* Deoployment file for a stateless app
* Service
* Ingress
* Service account 
* test template

We need to modify the below files:
* **values.yaml** to add desiered number of replicas, enable ingress, ingress class, choose image repo and tag, service port and adjust readiness and liveness probes
* **test-connection.yaml** to test the reachability to one of the routes like /products
* **ingress.yaml** to ommit hostname based routing and accept any IP

To make sure that chart values are Ok we need to test on Minikube
We will need to have the Docker image host on some sort of reachable container registry like Dockerhub. Later we will create ACR for hosting our Docker image
```bash
docker docker tag sampleflask:0.1 mohamedshokry/sampleflask:0.1
docker push mohamedshokry/sampleflask:0.1

# Create k8s cluster to use for testing
minikube start -p flask-app
cd flask-app-chart
helm upgrade --atomic --install pwc-flask-app --set image.repository=docker.io/mohamedshokry/sampleflask --set image.tag=0.1 .

# Check pods and ingress resources
kubectl get po
kubectl get svc
kubectl get ingress

Since there is no ingress installed now on minikube we can use port-forward to access the flask API from outside the minikube
kubectl port-forward -n default svc/pwc-flask-app 8000:5000
❯ curl -s http://localhost:8000/products | jq
[
  {
    "id": 1,
    "name": "Laptop"
  },
  {
    "id": 2,
    "name": "Smartphone"
  }
]
```


## 3- Create AKS using Terraform module
For this task terraform will be useful to spin AKS with Azure Gateway Ingress Controller (AGIC) enabled
Two main flavors supported for the deployment:
* Green field deploymet (Tested): Installing AKS, adding resource group, vnet, subnets and App gateway
* Brown field deployment (Under Testing): Instaling AKS and integrating with either separtly provisioned vnets, subnets and App gateway or pre existing ones

directory ```terraform-aks-provisioning``` in the repo contains needed terraform modules and files need to create the AKS, vnet, Application Gateway

***NOTE: terraform is created with azurerm backend portability of state file and lock mamnagement, This is very useful for the pipelines automation*** 

To provision the AKS along with resource group, vnet, subnet, App Gateway (This steps takes 20+ minutes)

Create a service principal to be used by terraform for Azure authentication:
```bash
az ad sp create-for-rbac --name "<SP Name>" --role Contributor --scopes /subscriptions/<Azure Subscription ID>
```
populate your service principal client_id, client_secret, tenant_id with your favourite way for example using hidden .env file
```bash
cat <<EOF > .env
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="12345678-0000-0000-0000-000000000000"
export ARM_TENANT_ID="10000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="20000000-0000-0000-0000-000000000000"
EOF

source .env
```

```bash
cd terraform-aks-provisioning
terraform init
terraform plan
terraform apply
```
The result AKs cluster will be provisioned with:
* Microsoft Entra authentication enabled and pre-created Entra group for AKS administration
* AGIC enabled and pods running

Ror more details about variables and it's default values check the README.md inside ```terraform-aks-provisioning``` directory

To connect to the AKS from the AKS portal you get the steps to connect like below:
```bash
az account set --subscription aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee
az aks get-credentials --resource-group <resource group name> --name <cluster name> --overwrite-existing
```


## 4- Deploy the flask application helm chart on AKS
Flask app hekm chart is contained in the repo in the directory ```flask-app-chart```
The application is a simple deployment with ClusterIP service to distribute at scale and ingress resource customized to use ```ingress.className: "azure-application-gateway"``` for our case since we will be using AGIC as an ingress controller

```bash
cd flask-app-chart
helm upgrade --atomic --install pwc-flask-app --set image.repository=docker.io/mohamedshokry/sampleflask --set image.tag=0.1 .
```

It should produce output like below:
```bash
Release "pwc-flask-app" does not exist. Installing it now.
NAME: pwc-flask-app
LAST DEPLOYED: Fri Oct 25 16:29:04 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  http://flaskapp.example.com/
```

After few minutes if we query the ingress resource we created using the helm chart we should see the public IP address associated to the Application gateway at terraform provisioning step as in the below example"
```bash
kubectl get ingress
NAME            CLASS                       HOSTS   ADDRESS          PORTS   AGE
pwc-flask-app   azure-application-gateway   *       135.237.76.147   80      22m
```

Here the application will be accessible at: http://135.237.76.147/products

## 5- Create Azure Container Registry
ACR creation is simple however it needs to be attached to the AKS to enable image pull. For Fixed AKS it's one time command but the challenge is when dealing with AKS as disposable cluster for the pipelines (The attach step should be executed either as part of AKS provisioning of as part of application deployment)

Example for ACR creation
```bash
MYACR=mycontainerregistry
az acr create --name $MYACR --resource-group myContainerRegistryResourceGroup --sku basic
```

Attach ACR to AKS
```bash
az aks update --name <AKS cluster name> --resource-group <AKS cluster resource group> --attach-acr <ACR name>
```

### Requiered customization for azure subscription
* Increase the vCPUs quota if you are using Pay As You Go plan
* Register for ```EncryptionAtHost```
    ```bash
    az feature register --name EncryptionAtHost  --namespace Microsoft.Compute
    ```

To this stage each of the application moving part are workinga and validated manually
***
# Application deployment using Jenkins
One of the fast options to get the pipeline ready is Jenkins. Below steps are done to creatre the Jenkins controler:
* Create Azure VM
* Install Jenkins using .dep packages to simplify the pipeline execution (it will be easy with native ubuntu 24.04 image than a container image)
    ```bash
        sudo apt update -y && sudo apt upgrade -y
        sudo apt install openjdk-21-jdk -y
        sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
        echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
        /etc/apt/sources.list.d/jenkins.list > /dev/null
        sudo apt update -y
        sudo apt install jenkins -y
        sudo systemctl start jenkins && sudo systemctl enable jenkins
    ```
The directory Jenkinsfiles contains the jenkins files used to automate each stage
we have now four pipelines
* **01-Flask-App-CI** : Get latest flask app Dockerfile from the repo, build the image and push it to ACR
* **02-AKS-Provision-Terraform** : Get latest Terraform files from the repo, initialize, plan and create the AKS
* **03-Deploy-Flask-App-Helm** : parametrized pipeline that get the latest helm chart from the repo and deploy it to AKS 
* **04-AKS-Destroy-Terraform** : Destroy AKS

***
**Notes about the pipelines:**
* Azure SP used details are saved as secrets and secret ID is shared with pipelines scripts
* terraform.tfvars is used as secret file
* pipelines are created lossly coupled with parameters to customize where to deploy at the same subscription and tenant
* Helm is using values files for customization. Helm Pipeline is exposing only commonly changed values like Helm release name, namespace, and image tag
***
# Automated Application deployment using Azure DevOps (Work In Progress)
To create the flow of CI/CD and Continuous deployment we will utilize Azure DevOps to create CI/CD pipeline and deploy the helm chart to the AKS

