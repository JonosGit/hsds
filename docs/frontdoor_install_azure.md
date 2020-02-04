Installation of Azure Front Door
=================================

Export environment variables as shown in "Sample .bashrc" below.

Summary of environment variables for Azure Front Door

FRONTDOORNAME - This (example myfrontdoor) value will become the prefix for the Front Door URL e.g https://myfrontdoor.azurefd.net
BACKENDADDRESS - The public IP of the Kubernetes Cluster. It can be obtained through kubectl get services.
FRIENDLYNAME - The name of the object in the Resource Group representing Azure FD.
PROTOCOL - The protocol expected by the Kubernetes load balancer (80/443). If SSL is being offloaded port 80 is likely in use.
ACCEPTED_PROTOCOLS - Determines whether http/https is allowed on the Front Door Public IP
FWDING_PROTOCOLS - Determines which protocols are forwarded from Front Door to the backend. 

Sample .bashrc
--------------

These environment variables will be use to configure Front Door

    export RESOURCEGROUP=myresouregroup
    export LOCATION=westus
    export FRONTDOORNAME=''
    export BACKENDADDRESS=''
    export FRIENDLYNAME=''
    export PROTOCOL='http'
    export ACCEPTED_PROTOCOLS='Https'
    export FWDING_PROTOCOLS='HttpsOnly'

1. Install or update az-cli `curl -L https://aka.ms/InstallAzureCli | bash`
2. Login to Azure Subscription using AZ-Cli. `$ az login`
3. Add the az front-door extension:
        `az extension add --name front-door`
4. The following command will create the new Front Door instance with SSL Offloading
        `az network front-door create --resource-group $RESOURCEGROUP --name $FRONTDOORNAME --backend-address $BACKENDADDRESS --friendly-name $FRIENDLYNAME --protocol $PROTOCOL --accepted-protocols $ACCEPTED_PROTOCOLS --forwarding-protocol $FWDING_PROTOCOLS`
5. Verify hsds Endpoints https://myfrontdoor.azurefd.net/about