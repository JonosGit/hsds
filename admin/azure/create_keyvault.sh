#!/bin/bash
RESOURCEGROUP=''
LOCATION='eastus'
KEY1='admin'
VALUE1='admin'
KEY2='testuser1'
VALUE2='test'
KEY3='testuser2'
VALUE3='test'
KEYVAULT='hsdskeyv1'
KEY4='acrpass'
VALUE4=''
KEY5='storageconnstring'
VALUE5=''

az group create -n $RESOURCE_GROUP -l $LOCATION
az keyvault create --name $KEYVAULT --resource-group $RESOURCE_GROUP --location $LOCATION
az keyvault secret set --vault-name $KEYVAULT --name $KEY1 --value $VALUE1
az keyvault secret set --vault-name $KEYVAULT --name $KEY2 --value $VALUE2
az keyvault secret set --vault-name $KEYVAULT --name $KEY3 --value $VALUE3
az keyvault secret set --vault-name $KEYVAULT --name $KEY4 --value $VALUE4
az keyvault secret set --vault-name $KEYVAULT --name $KEY5 --value $VALUE5

