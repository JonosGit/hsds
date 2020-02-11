#!/bin/bash
ACRNAME=''
ADMIN_PASSWORD=admin
BUCKET_NAME="home"
TAGVERSION="V1"
ACRPASS=$acrpass
ACRUSER=$ACRNAME
AZURE_CONNECTION_STRING=""


sudo apt-get update -qq
pip install aiohttp
pip install awscli
pip install requests
pip install pyflakes
pip install pytz

git clone https://github.com/HDFGroup/hsds
cd hsds
git checkout azure
echo "admin:admin" > ./admin/config/passwd.txt
echo "test_user1:test" >> ./admin/config/passwd.txt
bash ./build.sh
docker tag hdfgroup/hsds:latest $ACRNAME.azurecr.io/hdfgroup/hsds:$TAGVERSION
az acr login --name $ACRNAME -p $ACRPASS -u $ACRUSER
docker push $ACRNAME.azurecr.io/hdfgroup/hsds:$TAGVERSION
