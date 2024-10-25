# sample-Flask-AKS
Tutorial for dockerizing sample flask app and automate depoloyment to AKS using AzureDevOps


# Manaul provisoning steps for the flask application and the AKS
For manual trials clone the repo:
```
git clone https://github.com/mohamedmshokry/sample-Flask-AKS.git
```
### Creation and validation of the Flask app image
```bash 
docker build -t sampleflask:0.1 . 

# Spine a container from the image to check if teh flask app is working
docker run --name sampleflask -dp 8000:5000 sampleflask:0.1
```

### Provisioning Azure AKS cluster
For this task terraform will be useful to spin AKS with Azure Gateway Ingress Controller (AGIC) enabled
Two main flavors supported for the deployment:
* Green field deploymet (Tested): Installing AKS, adding resource group, vnet, subnets and App gateway
* Brown field deployment (Under Testing): Instaling AKS and integrating with either separtly provisioned vnets, subnets and App gateway or pre existing ones

directory ```terraform-aks-provisioning``` in the repo contains needed terraform modules and files need to create the AKS, vnet, Application Gateway

To provision the AKS along with resource group, vnet, subnet, App Gateway (This steps takes 30+ minutes)

populate your service principal client_id, client_secret, tenant_id with your favourate way for example using hidden .env file
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

Ror more details about variables and it's default values check the README.md inside ```terraform-aks-provisioning``` directory

### Deploy the flask application helm chart
Flask app is contained in the repo in the directory ```flask-app-chart```
The application is a simple deployment with ClusterIP service to distribute at scale and ingress resource customized to use ```ingress.className: "azure-application-gateway"``` for our case since we will be using AGIC as an ingress controller

```bash
cd flask-app-chart
helm upgrade --atomic --install pwc-flask-app .
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

# Automated Application deployment using Azure DevOps
To create the flow of CI/CD and Continuous deployment we will utilize Azure DevOps to create CI/CD pipeline and deploy the helm chart to the AKS

### Requiered customization for azure subscription
* Increase the vCPUs quota if you are using Pay As You Go plan
* Register for ```EncryptionAtHost```
    ```bash
    az feature register --name EncryptionAtHost  --namespace Microsoft.Compute
    ```