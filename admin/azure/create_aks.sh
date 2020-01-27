#!/bin/bash

# creates an Azure Kubernetes Cluster and attaches an existing ACR
sudo az aks install-cli
az acr login --name $ACRNAME
az aks create --resource-group $RESOURCEGROUP --name $AKSNAME --node-count 2 --enable-addons monitoring --attach-acr $ACRNAME
az aks get-credentials -g $RESOURCEGROUP -n $AKSNAME
