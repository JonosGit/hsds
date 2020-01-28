Installation with Azure Kubernetes
============================

Export environment variables as shown in "Sample .bashrc" below.

To deploy an Azure Storage Account, Azure Container Registry and Azure Kubernetes with HSDS Docker image

1. Install az-cli `curl -L https://aka.ms/InstallAzureCli | bash`
2. Login to Azure Subscription using AZ-Cli. `$ az login`
3. Run the following commands to create Azure Resource Group:
        `$ az group create --name $RESOURCEGROUP --location $LOCATION`
4. Create storage account `az storage account create -n $STORAGEACCTNAME -g $RESOURCEGROUP -l $LOCATION --sku Standard_LRS`
5. Create a storage container `az storage container create -n MyStorageContainer --fail-on-exist`
6. The following command will create the new ACR
        `$ az acr create --resource-group $RESOURCEGROUP --name $ACRNAME --sku Basic --admin-enabled true`
7. Run az acr import
    `az acr import -n $ACRNAME --source docker.io/hdfgroup/hsds:latest --image hdfgroup/hsds:v1`
8. Pull the image down via docker or login to Azure Container Registry via docker and modify as needed (see Local docker image deployment below). `docker login --username $ACRNAME --password $AZDOCKERPASS $ACRNAME.azurecr.io`
9. Install AKS cli`az aks install-cli`
10. Create AKS Cluster and attach to ACR `az aks create -n $AKSCLUSTER -g $RESOURCEGROUP --generate-ssh-keys --attach-acr $ACRNAME`
11. Login to AKS Cluster `az aks get-credentials -g $RESOURCEGROUP -n $AKSNAME`

To deploy to an existing ACR/AKS instace from HDFGroup Git repo local Docker image

1. Install AKS cli`az aks install-cli`
2. Login to AKS Cluster `az aks get-credentials -g $RESOURCEGROUP -n $AKSNAME`
3. Get project source code: `$ git clone https://github.com/HDFGroup/hsds`
4. Create RBAC roles `kubectl create -f k8s_rbac.yml`
5. For HSDS to be used only within the cluster apply: `$ kubectl apply -f k8s_service.yml`.  Or for HSDS to be available externally, customize k8s_service_lb.yml with an ssl cert identifier and apply: `$ kubectl apply -f k8s_service_lb.yml`
6. Go to admin/config directory: `$ cd hsds/admin/config`
7. Copy the file "passwd.default" to "passwd.txt".  Add any usernames/passwords you wish
8. From hsds directory, build docker image:  `$ docker build -t hdfgroup/hsds .`
9. Tag the docker image using the ACR scheme: `$ docker tag hdfgroup/hsds $ACRNAME.azurecr.io/hsds:v1`  where $ACRNAME is the ACR being deployed too, and v1 is the version (update this everytime you will be deploying a new version of HSDS)
10. Obtain the credentials to login to the container registry: `$ az acr login --name $ACRNAME`.
11. Push the image to Azure ACR: `$ docker push $ACRNAME.azurecr.io/hsds:v1`
12. In k8s_deployment.yml, customize the values for AWS_S3_GATEWAY, AWS_REGION, BUCKET_NAME, LOG_LEVEL, SERVER_NAME, HSDS_ENDPOINT, GREETING, AZURE_CONNECTION_STRING and ABOUT based on the AWS region you will be deploying to and values desired for your installation. Next update the image: myacr.azurecr.io/hdfgroup/hsds:v1" to reflect the attached acr repository for deployment.
13. Apply the deployment: `$ kubectl apply -f k8s_deployment.yml`
14. Verify that the HSDS pod is running: `$ kubectl get pods`.  A pod with a name starting with hsds should be displayed with status as "Running".
15. Tail the pod logs (`$ kubectl logs -f hsds-1234 sn`) till you see the line: `All nodes healthy, changing cluster state to READY` (requires log level be set to INFO or lower)
16. Create a forwarding port to the Kubernetes service: `$ sudo kubectl port-forward hsds-1234 80:5101`
17. Add the DNS for the service to the /etc/hosts file.  E.g. `127.0.0.1  hsds.hdf.test` (use the DNS name given in k8s_deployment.yml)
18. Go to <http://hsds.hdf.test/about> and verify that "cluster_state" is "READY"
19. Install Anaconda: <https://conda.io/docs/user-guide/install/linux.html>  (install for python 3.7)
20. Install h5pyd: `$ pip install h5pyd`
21. Run: `$ hsconfigure`.  Set hs endpoint with DNS name (e.g. <http://hsds.hdf.test>) and admin username/password.  Ignore API Key.
22. Run: `$ hsinfo`.  Server state should be "`READY`".  Ignore the "Not Found" error for the admin home folder
23. Create "/home" folder: `$ hstouch /home/`.  Note: trailing slash is important!
24. For each username in the passwd file, create a top-level domain: `$ hstouch -o <username> /home/<username>/`
25. Run the integration test: `$ python testall.py --skip_unit`
26. The test suite will emit some warnings due to test domains not being loaded.  To address see test_data_setup below.
27. To scale up or down the number of HSDS pods, run: `$ kubectl scale --replicas=n deployment/hsds` where n is the number of pods desired.
28. If enabling external access to the service, create a DNS record for the HSDS endpoint to the DNS name of the load balancer

Sample .bashrc
--------------

These environment variables will be passed to the Docker containers on start up.

    export AZURE_CONNECTION_STRING=1234567890      # use the connection string for your Azure account 
    export BUCKET_NAME=hsds.test                   # set to the name of the container you will be using
    export HDF5_SAMPLE_BUCKET=""
    export RESOURCEGROUP=myresouregroup
    export AKSCLUSTER=myakscluster
    export LOCATION=westus
    export ACRNAME=myacrname
    export STORAGEACCTNAME=mystorageaccount


Test Data Setup
---------------

Using the following procedure to import test files into hsds

1. Install h5py: `$ pip install h5py`
2. Install h5pyd (Python client SDK): `$ pip install h5pyd`
3. Download the following file: `$ wget https://s3.amazonaws.com/hdfgroup/data/hdf5test/tall.h5`
4. In the following steps use the password that was setup for the test_user1 account in place of \<passwd\>
5. Create a test folder on HSDS: `$ hstouch -u test_user1 -p <passwd> /home/test_user1/test/` 
6. Import into hsds: `$ hsload -v -u test_user1 -p <passwd> tall.h5 /home/test_user1/test/`
7. Verify upload: `$ hsls -r -u test_user1 -p <passwd> /home/test_user1/test/tall.h5
