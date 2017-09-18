#!/bin/bash

echo "Create Foundation S3 bucket: awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.foundation"
aws s3api head-bucket --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.foundation" --region "${REGION}" 2> /dev/null ||
  aws s3 mb s3://awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.foundation  --region "${REGION}" # Foundation configs
aws s3api put-bucket-versioning --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.foundation" --versioning-configuration Status=Enabled --region "${REGION}"

echo "Create InfraDev S3 bucket: awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev"
aws s3api head-bucket --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev" --region "${REGION}" 2> /dev/null ||
  aws s3 mb s3://awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev --region "${REGION}" # Storage for InfraDev
aws s3api put-bucket-versioning --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev" --versioning-configuration Status=Enabled --region "${REGION}"

echo "Create Build Artifacts S3 bucket: awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.build"
aws s3api head-bucket --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.build" --region "${REGION}" 2> /dev/null ||
  aws s3 mb s3://awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.build --region "${REGION}" # Build artifacts, etc
aws s3api put-bucket-versioning --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.build" --versioning-configuration Status=Enabled --region "${REGION}"
