Installation with Docker
========================

Export environment variables as shown in "Sample .bashrc" below.

1. Install Python 3 (e.g. with Miniconda <https://docs.conda.io/en/latest/miniconda.html>)
2. Install awscli Python packages (`$pip install awscli`)
3. Install aiohttp Python package (`$pip install aiohttp`)
4. Install Docker and docker-compose if necessary (see "Docker Setup" below)
5. Create a bucket for HSDS, using aws cli tools or aws management console
6. Get project source code: `$ git clone https://github.com/HDFGroup/hsds`
7. Go to admin/config directory: `$ cd hsds/admin/config`
8. Copy the file "passwd.default" to "passwd.txt".  Add any usernames/passwords you wish.  Modify existing passwords (for admin, test_user1, test_user2) for security.
9. Create environment variables as in "Sample .bashrc" below
10. From hsds directory, build docker image:  `$ docker build -t hdfgroup/hsds .`
11. Start the service `$./runall.sh <n>` where n is the number of containers desired (defaults to 1)
12. Run `$ docker ps` and verify that the containers are running: hsds_head, hsds_sn_[1-n], hsds_dn_[1-n]
13. Add the DNS for the service to the /etc/hosts file.  E.g. `127.0.0.1  hsds.hdf.test`
14. Go to <http://hsds.hdf.test/about> and verify that "cluster_state" is "READY" (might need to give it a minute or two)
15. Run the integration test: `$ python testall.py --skip_unit`
16. The test suite will emit some warnings due to test domains not being loaded.  To address see "Post Install configuration" below.

Sample .bashrc
--------------

These environment variables will be passed to the Docker containers on start up.

    export AWS_ACCESS_KEY_ID=1234567890            # user your AWS account access key if using S3 (Not needed if running on EC2 and AWS_IAM_ROLE is defined)
    export AWS_SECRET_ACCESS_KEY=ABCDEFGHIJKL      # use your AWS account access secret key if using S3  (Not needed if running on EC2 and AWS_IAM_ROLE is defined)
    export BUCKET_NAME=hsds.test                   # set to the name of the bucket you will be using
    export AWS_REGION=us-east-1                    # for boto compatibility - for S3 set to the region the bucket is in
    export AWS_S3_GATEWAY=http://s3.amazonaws.com  # Use AWS endpoint for region where bucket is
    export HSDS_ENDPOINT=http://hsds.hdf.test    # use https protocal if SSL is desired
    # For S3, set AWS_S3_GATEWAY to endpoint for the region the bucket is in.  E.g.: http://s3.amazonaws.com.
    # See http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region for list of endpoints.

Docker Setup
------------

The following are instructions for installing docker on Linux/CentOS.  Details for other Linux distros
may vary.  For OS X, see: <https://docs.docker.com/engine/installation/>.

Run the following commands to install Docker on Linux/CentOS:

    $ sudo yum install docker
    $ sudo service docker start
    $ sudo chkconfig --level 300 docker on
    $ sudo groupadd docker # if group docker doesn't exist already
    $ sudo gpasswd -a $USER docker
    # log out and back in again (may also need to stop/start docker service)
    $ docker ps  # verify

Install docker-compose.  See: <https://docs.docker.com/compose/install/>

Post Install Configuration
--------------------------

The following is some optional configuration steps to create test files and configure
user home folders.

1. Install h5py: `$ pip install h5py`
2. Install h5pyd (Python client SDK): `$ pip install h5pyd`
3. Download the following file: `$ wget https://s3.amazonaws.com/hdfgroup/data/hdf5test/tall.h5`
4. In the following steps use the password that was setup for the test_user1 account in place of \<passwd\>
5. Create a test folder on HSDS: `$ hstouch -u test_user1 -p <passwd> /home/test_user1/test/` 
6. Import into hsds: `$ hsload -v -u test_user1 -p <passwd> tall.h5 /home/test_user1/test/`
7. Verify upload: `$ hsls -r -u test_user1 -p <passwd> /home/test_user1/test/tall.h5
8. To setup home folders, for each username in the passwd file (other than admin and test_user1), create a top-level domain: `$ hstouch -o <username> /home/<username>/`

Installing Software Updates
---------------------------

To get the latest codes changes from the HSDS repo do the following:

1. Shutdown the service: `$ stopall.sh`
2. Get code changes: `$ git pull`
3. Build a new Docker image: `$ docker-compose build
4. Start the service: `$ ./runall.sh`
