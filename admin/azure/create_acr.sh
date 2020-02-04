#!/bin/bash
az group create --name $RESOURCEGROUP --location $LOCATION
az acr create --resource-group $RESOURCEGROUP --name $ACRNAME --sku Basic --admin-enabled true
az acr login --name $ACRNAME
