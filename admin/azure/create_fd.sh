#!/bin/bash
# creates an Azure Front Door with SSL Offloading configured
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

