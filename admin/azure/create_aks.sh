#!/bin/bash
AKSNAME=""
RESOURCEGROUP=""
ACRNAME=""
# creates an Azure Kubernetes Cluster and attaches an existing ACR
az aks install-cli

az acr login --name $ACRNAME
az aks create --resource-group $RESOURCEGROUP --name $AKSNAME --node-count 2 --generate-ssh-keys --enable-addons monitoring --attach-acr $ACRNAME
az aks get-credentials -g $RESOURCEGROUP -n $AKSNAME
kubectl create -f k8s_rbac.yml
kubectl apply -f k8s_service_lb_azure.yml
kubectl apply -f k8s_deployment_azure.yml
