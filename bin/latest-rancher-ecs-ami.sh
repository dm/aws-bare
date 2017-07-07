#!/bin/bash

# Get latest Rancher AMI_ID
: ${REGION?"Need to set AWS Region in REGION env var"}

if [ ! -f ".${REGION}_rancher_ecs_ami_id" ]; then
  curl -s 'https://raw.githubusercontent.com/rancher/rancher.github.io/master/os/amazon-ecs/index.md' | \
  awk "/launchInstanceWizard:ami=ami-/&&/HVM/&&/${REGION}/" | cut -d "[" -f2 | \
  cut -d "]" -f1 > ".${REGION}_rancher_ecs_ami_id"
fi
