#!/bin/bash

echo "Create Foundation S3 bucket: awsrig.${PROJECT}.${NAME_SUFFIX}.foundation"
aws s3api head-bucket --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.foundation" --region "${REGION}" ||
  aws s3 mb s3://awsrig.${PROJECT}.${NAME_SUFFIX}.foundation  --region "${REGION}" # Foundation configs
aws s3api put-bucket-versioning --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.foundation" --versioning-configuration Status=Enabled --region "${REGION}"

echo "Create InfraDev S3 bucket: awsrig.${PROJECT}.${NAME_SUFFIX}.infradev"
aws s3api head-bucket --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.infradev" --region "${REGION}" ||
  aws s3 mb s3://awsrig.${PROJECT}.${NAME_SUFFIX}.infradev --region "${REGION}" # Storage for InfraDev
aws s3api put-bucket-versioning --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.infradev" --versioning-configuration Status=Enabled --region "${REGION}"

echo "Create Build Artifacts S3 bucket: awsrig.${PROJECT}.${NAME_SUFFIX}.build"
aws s3api head-bucket --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.build" --region "${REGION}" ||
  aws s3 mb s3://awsrig.${PROJECT}.${NAME_SUFFIX}.build --region "${REGION}" # Build artifacts, etc
aws s3api put-bucket-versioning --bucket "awsrig.${PROJECT}.${NAME_SUFFIX}.build" --versioning-configuration Status=Enabled --region "${REGION}"
