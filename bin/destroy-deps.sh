#!/bin/bash

echo 'This script will remove the (empty only) S3 dependency buckets...'

# Purposely don't use '--force' to ensure people have gone through the contents
: ${PROJECT?"Need to set project name in PROJECT env var"}
: ${NAME_SUFFIX?"Need to set name suffix in NAME_SUFFIX env var"}

# Create confirmation etc:
aws s3 rb s3://awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.foundation
aws s3 rb s3://awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev
aws s3 rb s3://awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.build
