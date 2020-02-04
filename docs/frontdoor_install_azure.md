Installation of Azure Front Door
=================================

Export environment variables as shown in "Sample .bashrc" below.

Sample .bashrc
--------------

These environment variables will be use to configure Front Door

    export RESOURCEGROUP=myresouregroup
    export LOCATION=westus
    export FRONTDOORNAME=''
    export BACKENDADDRESS=''
    export FRIENDLYNAME=''
    export LOCATION=''
    export PROTOCOL='http'
    export ACCEPTED_PROTOCOLS='Https'
    export FWDING_PROTOCOLS='HttpsOnly'

1. Install or update az-cli `curl -L https://aka.ms/InstallAzureCli | bash`
2. Login to Azure Subscription using AZ-Cli. `$ az login`
3. Add the az front-door extension:
        `az extension add --name front-door`
4. The following command will create the new Front Door instance with SSL Offloading
        `az network front-door create --resource-group $RESOURCEGROUP --name $FRONTDOORNAME --backend-address $BACKENDADDRESS --friendly-name $FRIENDLYNAME --protocol $PROTOCOL --accepted-protocols $ACCEPTED_PROTOCOLS --forwarding-protocol $FWDING_PROTOCOLS`
