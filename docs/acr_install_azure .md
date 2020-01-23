Installation of ACR (Azure Container Registry)
=================================


1. Install Azure CLI https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
2. Login to Azure Subscription using AZ-Cli.
    az login
3. After setting the necessary variables (ResourceGroup, Location and ACRNAME) Run the following commands to create Azure Resource Group and new ACR:
    az group create --name $RESOURCEGROUP --location $LOCATION
    az acr create --resource-group $RESOURCEGROUP --name $ACRNAME --sku Basic --admin-enabled true


Import Public Docker Registry resources into ACR
=================================

        1. Login to ACR via az acr
        az acr login --name $ACRNAME
        2. Login to ACR via docker **Note the admin password was created when the acr was created and is available in the portal if needed.
        docker login --username $ACRNAME --password $AZDOCKERADMINPASS $ACRNAME.azurecr.io
        3. Run az acr import
        az acr import -n $ACRNAME --source docker.io/library/hdfgroup/python:3.7 -t targetrepository:targettag
