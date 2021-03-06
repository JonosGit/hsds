Installation with Azure Kubernetes
============================

Export environment variables as shown in "Sample .bashrc" below.

1. Install AKS cli`az aks install-cli`
2. Create AKS Cluster and attach to ACR `az aks create -n $AKSCLUSTER -g $RESOURCEGROUP --generate-ssh-keys --attach-acr $ACRNAME` In order to leverage RBAC with Kubernetes Azure AAD must be configured prior to cluster creation. See example automation at <https://github.com/Azure-Samples/azure-cli-samples/blob/master/aks/azure-ad-integration>
3. Create a storage account container for HSDS, using AZ cli tools or Azure Storage console
4. Get project source code: `$ git clone https://github.com/HDFGroup/hsds`
5. Apply RBAC after creating required aad components <https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration-cli>
6. For HSDS to be used only within the cluster apply: `$ kubectl apply -f k8s_service.yml`.  Or for HSDS to be available externally, customize k8s_service_lb.yml with an ssl cert identifier and apply: `$ kubectl apply -f k8s_service_lb.yml`
7. Go to admin/config directory: `$ cd hsds/admin/config`
8. Copy the file "passwd.default" to "passwd.txt".  Add any usernames/passwords you wish
9. From hsds directory, build docker image:  `$ docker build -t hdfgroup/hsds .`
10. Tag the docker image using the ACR scheme: `$ docker tag hdfgroup/hsds $ACRNAME.azurecr.io/hsds:v1`  where $ACRNAME is the ACR being deployed too, and v1 is the version (update this everytime you will be deploying a new version of HSDS)
11. Obtain the credentials to login to the AWS container registry: `$ az acr login --name $ACRNAME`.
12. Push the image to Azure ACR: `$ docker push $ACRNAME.azurecr.io/hsds:v1`
13. In k8s_deployment.yml, customize the values for AWS_S3_GATEWAY, AWS_REGION, BUCKET_NAME, LOG_LEVEL, SERVER_NAME, HSDS_ENDPOINT, GREETING, AZURE_CONNECTION_STRING and ABOUT based on the AWS region you will be deploying to and values desired for your installation. Next update the image: myacr.azurecr.io/hdfgroup/hsds:v1" to reflect the attached acr repository for deployment.
14. Apply the deployment: `$ kubectl apply -f k8s_deployment.yml`
15. Verify that the HSDS pod is running: `$ kubectl get pods`.  A pod with a name starting with hsds should be displayed with status as "Running".
16. Tail the pod logs (`$ kubectl logs -f hsds-1234 sn`) till you see the line: `All nodes healthy, changing cluster state to READY` (requires log level be set to INFO or lower)
17. Create a forwarding port to the Kubernetes service: `$ sudo kubectl port-forward hsds-1234 80:5101`
18. Add the DNS for the service to the /etc/hosts file.  E.g. `127.0.0.1  hsds.hdf.test` (use the DNS name given in k8s_deployment.yml)
19. Go to <http://hsds.hdf.test/about> and verify that "cluster_state" is "READY"
20. Install Anaconda: <https://conda.io/docs/user-guide/install/linux.html>  (install for python 3.7)
21. Install h5pyd: `$ pip install h5pyd`
22. Run: `$ hsconfigure`.  Set hs endpoint with DNS name (e.g. <http://hsds.hdf.test>) and admin username/password.  Ignore API Key.
23. Run: `$ hsinfo`.  Server state should be "`READY`".  Ignore the "Not Found" error for the admin home folder
24. Create "/home" folder: `$ hstouch /home/`.  Note: trailing slash is important!
25. For each username in the passwd file, create a top-level domain: `$ hstouch -o <username> /home/<username>/`
26. Run the integration test: `$ python testall.py --skip_unit`
27. The test suite will emit some warnings due to test domains not being loaded.  To address see test_data_setup below.
28. To scale up or down the number of HSDS pods, run: `$ kubectl scale --replicas=n deployment/hsds` where n is the number of pods desired.
29. If enabling external access to the service, create a DNS record for the HSDS endpoint to the DNS name of the load balancer

Sample .bashrc
--------------

These environment variables will be passed to the Docker containers on start up.

    export AZURE_CONNECTION_STRING=1234567890      # use the connection string for your Azure account 
    export BUCKET_NAME=hsds.test                   # set to the name of the container you will be using
    export HDF5_SAMPLE_BUCKET=""
    export AWS_ACCESS_KEY_ID=1234567890            # user your AWS account access key if using S3 (Not needed if running on EC2 and AWS_IAM_ROLE is defined)
    export AWS_SECRET_ACCESS_KEY=ABCDEFGHIJKL      # use your AWS account access secret key if using S3  (Not needed if running on EC2 and AWS_IAM_ROLE is defined)
    export AWS_REGION=us-east-1                    # for boto compatibility - for S3 set to the region the bucket is in
    export AWS_S3_GATEWAY=http://s3.amazonaws.com  # Use AWS endpoint for region where bucket is
    export HSDS_ENDPOINT=http://hsds.hdf.test    # use https protocal if SSL is desired
    # For S3, set AWS_S3_GATEWAY to endpoint for the region the bucket is in.  E.g.: http://s3.amazonaws.com.
    # See http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region for list of endpoints.


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
