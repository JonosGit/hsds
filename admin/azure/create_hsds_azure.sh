#!/bin/bash
export STORAGEACCTNAME=''
export RESOURCEGROUP=''
export LOCATION='eastus'
export STORAGEKIND='StorageV2'
export STORAGESKU='Standard_LRS'
export CONTAINERNAME='home'
export ACRNAME=''
export AKSNAME=''
export KEYVAULTNAME=''

# This script creates Azure Storage, Azure ACR and AKS clusters as well as a Key Vault instance. The ACR password and storage account keys are placed in Keyvault during script execution.
# create storage instance and container
az group create -n $RESOURCEGROUP -l $LOCATION
az storage account create -n $STORAGEACCTNAME -g $RESOURCEGROUP -l $LOCATION --sku $STORAGESKU --kind $STORAGEKIND
strconn=$(az storage account show -g $RESOURCEGROUP -n $STORAGEACCTNAME --query id)
RESID=$(eval echo $strconn)
az storage account show -g $RESOURCEGROUP -n $STORAGEACCTNAME --query id
az storage container create -n $CONTAINERNAME --account-name $STORAGEACCTNAME

# create ACR instance
az acr create -n $ACRNAME -g $RESOURCEGROUP --sku Standard --location $LOCATION --admin-enabled true
acrpass=`az acr credential show -n $ACRNAME --query passwords[0].value`

# create AKS cluster
az acr login --name $ACRNAME
az aks create -g $RESOURCEGROUP -n $AKSNAME --node-count 2 --generate-ssh-keys --enable-addons monitoring --attach-acr $ACRNAME
az aks get-credentials -g $RESOURCEGROUP -n $AKSNAME

# create Key Vault and set ACR password secret to keyvault
az keyvault create --location $LOCATION --name $KEYVAULTNAME --resource-group $RESOURCEGROUP
az keyvault secret set --vault-name $KEYVAULTNAME --name acr1 --value $acrpass

# add storage account to keyvault
az role assignment create --role "Storage Account Key Operator Service Role" --scope $RESID --assignee cfa8b339-82a2-471a-a3c9-0fc0be7a4093
az keyvault storage add --vault-name $KEYVAULTNAME -n $STORAGEACCTNAME --active-key-name key1 --auto-regenerate-key --regeneration-period P90D  --resource-id $RESID

