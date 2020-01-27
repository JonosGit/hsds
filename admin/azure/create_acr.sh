#!/bin/bash

# Creates a resource group and Azure Container Registry and imports that latest hsds image
# Requires Az-cli 

az group create --name $RESOURCEGROUP --location $LOCATION
az acr create --resource-group $RESOURCEGROUP --name $ACRNAME --sku Basic
az acr login --name $ACRNAME
az acr import -n $ACRNAME --source docker.io/hdfgroup/hsds:latest --image hdfgroup/hsds:v1
