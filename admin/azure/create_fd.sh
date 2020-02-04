#!/bin/bash
# creates an Azure Front Door with SSL Offloading configured
# 
# FRONTDOORNAME - This (example myfrontdoor) value will become the prefix for the Front Door URL e.g https://myfrontdoor.azurefd.net
# BACKENDADDRESS - The public IP of the Kubernetes Cluster. It can be obtained through kubectl get services.
# FRIENDLYNAME - The name of the object in the Resource Group representing Azure FD.
# PROTOCOL - The protocol expected by the Kubernetes load balancer (80/443). If SSL is being offloaded port 80 is likely in use.
# ACCEPTED_PROTOCOLS - Determines whether http/https is allowed on the Front Door Public IP
# FWDING_PROTOCOLS - Determines which protocols are forwarded from Front Door to the backend. 

FRONTDOORNAME=''
RESOURCEGROUP=''
BACKENDADDRESS=''
FRIENDLYNAME=''
LOCATION=''
PROTOCOL='http'
ACCEPTED_PROTOCOLS='Https'
FWDING_PROTOCOLS='HttpsOnly'


az group create --name $RESOURCEGROUP --location $LOCATION
az extension add --name front-door
az network front-door create --resource-group $RESOURCEGROUP --name $FRONTDOORNAME --backend-address $BACKENDADDRESS --friendly-name $FRIENDLYNAME --protocol $PROTOCOL --accepted-protocols $ACCEPTED_PROTOCOLS --forwarding-protocol $FWDING_PROTOCOLS

