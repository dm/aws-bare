#!/bin/bash

# Get latest ubuntu AMI_ID
: ${REGION?"Need to set AWS Region in REGION env var"}

if [ ! -f ".${REGION}_ubuntu_ami_id" ]; then
  curl -s "http://cloud-images.ubuntu.com/query/xenial/server/released.current.txt" | \
  awk "/ebs-ssd/&&/amd64/&&/hvm/&&/${REGION}/" | cut -f8 -d$'\t' > ".${REGION}_ubuntu_ami_id"
fi
