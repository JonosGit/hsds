#!/bin/bash
AZURE_STORAGE_ACCOUNT=$STORAGEACCTNAME
# creates an Azure Kubernetes Cluster and attaches an existing ACR
# curl -L https://aka.ms/InstallAzureCli | bash
az storage account create -n $STORAGEACCTNAME -g $RESOURCEGROUP -l $LOCATION --sku Standard_LRS --kind V2
az storage container create -n $CONTAINERNAME --fail-on-exist
