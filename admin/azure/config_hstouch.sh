#!/bin/bash
# Update the -p prior to running
# Run hsconfigure/hsinfo prior to running

wget https://s3.amazonaws.com/hdfgroup/data/hdf5test/tall.h5
hstouch -u admin -p **** /home/
hstouch -u admin -p **** -o test_user1 /home/test_user1/
hstouch -u admin -p **** -o test_user1 /home/test_user1/test/
hsload -v -u test_user1 -p **** tall.h5 /home/test_user1/test/