#!/bin/bash
RESOURCEGROUP='myresgroup'
LOCATION='eastus'
ACRNAME='hsdsacr1'
IMAGENAME='python'
TARGETREPO='hsds'
TARGETTAG='v1'
AKSCLUSTER='hsdsaks1'
AZDOCKERADMINPASS=''

# script to create acr/aks instances in azure and populate acr with hdfgroup docker image 

az group create --name $RESOURCEGROUP --location $LOCATION
az acr create --resource-group $RESOURCEGROUP --name $ACRNAME --sku Basic --admin-enabled true
az acr login --name $ACRNAME
docker login --username $ACRNAME --password $AZDOCKERADMINPASS $ACRNAME.azurecr.io
az acr import -n $ACRNAME --source docker.io/library/hdfgroup/python:3.7 -t $IMAGENAME:$TARGETTAG

