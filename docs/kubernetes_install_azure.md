Installation with Azure Kubernetes
============================

Export environment variables as shown in "Sample .bashrc" below.

Sample .bashrc
--------------

These environment variables will be passed to the Docker containers on start up.

    export AZURE_CONNECTION_STRING=1234567890      # use the connection string for your Azure account 
    export BUCKET_NAME=test                  # set to the name of the container you will be using
    export RESOURCEGROUP=myresouregroup
    export AKSCLUSTER=myakscluster
    export LOCATION=westus
    export ACRNAME=myacrname
    export STORAGEACCTNAME=mystorageaccount
    export CONTAINERNAME=testcontainer


To deploy an Azure Storage Account, Azure Container Registry and Azure Kubernetes

1. Install az-cli `curl -L https://aka.ms/InstallAzureCli | bash`
2. Validate runtime version az-cli is greater then 2.0.80 `az version`
3. Login to Azure Subscription using AZ-Cli. `$ az login`
4. Run the following commands to create Azure Resource Group:
        `$ az group create --name $RESOURCEGROUP --location $LOCATION`
5. Create storage account and container (see /admin/azure/create_storage.sh for example): `az storage account create -n $STORAGEACCTNAME -g $RESOURCEGROUP -l $LOCATION --sku Standard_LRS`
6. The following command will create the new ACR (see /admin/azure/create_acr.sh for example):
        `$ az acr create --resource-group $RESOURCEGROUP --name $ACRNAME --sku Basic --admin-enabled true`
7. Install AKS cli`az aks install-cli`
8. Create AKS Cluster and attach to ACR `az aks create -n $AKSCLUSTER -g $RESOURCEGROUP --generate-ssh-keys --attach-acr $ACRNAME`
9. Login to AKS Cluster `az aks get-credentials -g $RESOURCEGROUP -n $AKSNAME`

To deploy an HSDS docker image to Azure ACR and AKS Cluster

1. Login to AKS Cluster `az aks get-credentials -g $RESOURCEGROUP -n $AKSNAME`
2. Get project source code: `$ git clone https://github.com/HDFGroup/hsds`
3. Create RBAC roles `kubectl create -f k8s_rbac.yml`
4. For HSDS to be used only within the cluster apply: `$ kubectl apply -f k8s_service_azure.yml`.  Or for HSDS to be available externally, customize k8s_service_lb_azure.yml and apply: `$ kubectl apply -f k8s_service_lb_azure.yml` By default port 80 will be configured. Modify as needed. For additional configuration options to handle SSL related scenerios see Azure Front Door <https://docs.microsoft.com/en-us/azure/frontdoor/>.
5. Go to admin/config directory: `$ cd hsds/admin/config`
6. Copy the file "passwd.default" to "passwd.txt".  Add any usernames/passwords you wish
7. From hsds directory, build docker image:  `$bash build.sh`
8. Tag the docker image using the ACR scheme: `$ docker tag hdfgroup/hsds $ACRNAME.azurecr.io/hsds:v1`  where $ACRNAME is the ACR being deployed too, and v1 is the version (update this everytime you will be deploying a new version of HSDS)
9. Obtain the credentials to login to the container registry: `$ az acr login --name $ACRNAME`.
10. Push the image to Azure ACR: `$ docker push $ACRNAME.azurecr.io/hsds:v1`
11. In k8s_deployment_azure.yml, customize the values for AZURE_CONNECTION_STRING and BUCKET_NAME. Next update the image string to reflect the ACR previously deployed: 'myacr.azurecr.io/hdfgroup/hsds:v1'.
12. Apply the deployment: `$ kubectl apply -f k8s_deployment_azure.yml`
13. Verify that the HSDS pod is running: `$ kubectl get pods`.  A pod with a name starting with hsds should be displayed with status as "Running".
14. Tail the pod logs (`$ kubectl logs -f hsds-1234 sn`) till you see the line: `All nodes healthy, changing cluster state to READY` (requires log level be set to INFO or lower)
15. Create a forwarding port to the Kubernetes service (if no loadbalancer is in use): `$ sudo kubectl port-forward hsds-1234 80:5101`
16. Add the DNS for the service to the /etc/hosts file.  E.g. `127.0.0.1  hsds.hdf.test` (use the DNS name given in k8s_deployment.yml)
17. Go to <http://hsds.hdf.test/about> and verify that "cluster_state" is "READY"

Additional commands

1. To scale up or down the number of HSDS pods, run: `$ kubectl scale --replicas=n deployment/hsds` where n is the number of pods desired.

Test Data Setup
---------------

Using the following procedure to import test files into hsds

1. Install Anaconda: <https://conda.io/docs/user-guide/install/linux.html>  (install for python 3.7)
2. Install h5py: `$ pip install h5py`
3. Install h5pyd (Python client SDK): `$ pip install h5pyd`
4. Run: `$ hsconfigure`.  Set hs endpoint with DNS name (e.g. <http://hsds.hdf.test>) and admin username/password.  Ignore API Key.
5. Run: `$ hsinfo`.  Server state should be "`READY`".  Ignore the "Not Found" error for the admin home folder
6. Create test user environment and test data (see /admin/azure/config_hstouch.sh for example)
7. Run the integration test: `$ python testall.py --skip_unit`
