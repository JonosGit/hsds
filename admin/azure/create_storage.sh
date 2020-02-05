#!/bin/bash
AZURE_STORAGE_ACCOUNT=$STORAGEACCTNAME
# creates an Azure Storage Account and Container

az storage account create -n $STORAGEACCTNAME -g $RESOURCEGROUP -l $LOCATION --sku Standard_LRS --kind Storagev2
az storage container create -n $CONTAINERNAME --fail-on-exist
