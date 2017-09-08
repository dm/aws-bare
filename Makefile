include .make

export APP ?= appname
export DOMAIN ?= example.tld
export EMAIL ?= user@example.com
export ENV ?= dev
export KEY_NAME ?= ""
export NAME_SUFFIX ?= awsrig-test-bucket
export PROFILE ?= default
export PROJECT ?= projectname
export REGION ?= us-east-1

export AWS_PROFILE=${PROFILE}
export AWS_REGION=${REGION}


## Create dependency S3 buckets
# Used for storage of Foundation configs, InfraDev storage and Build artifacts
# These are created outside Terraform since it'll store sensitive contents!
# When completely empty, can be destroyed with `make destroy-deps`
deps:
	@./bin/create-buckets.sh

# Destroy dependency S3 buckets, only destroy if empty
destroy-deps:
	@if ${MAKE} .prompt-yesno message="Are you sure you wish to delete the dependency S3 buckets?"; then \
		sh ./bin/destroy-deps.sh; \
	fi

## Creates Foundation and Build DevOps Pipeline
create-pipeline: upload-pipeline
	@aws cloudformation create-stack --stack-name "${PROJECT}-${NAME_SUFFIX}-pipeline" \
		--capabilities CAPABILITY_NAMED_IAM \
		--disable-rollback \
		--parameters \
			"ParameterKey=BuildArtifactsBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.build" \
			"ParameterKey=Environment,ParameterValue=all" \
			"ParameterKey=FoundationBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.foundation" \
			"ParameterKey=GithubBranch,ParameterValue=${GITHUB_BRANCH}" \
			"ParameterKey=GithubOAuthToken,ParameterValue=${GITHUB_OAUTH_TOKEN}" \
			"ParameterKey=GithubOwner,ParameterValue=${GITHUB_OWNER}" \
			"ParameterKey=GithubRepo,ParameterValue=${GITHUB_REPO}" \
			"ParameterKey=InfraDevBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.infradev" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=NameSuffix,ParameterValue=${NAME_SUFFIX}" \
		--region ${REGION} \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${NAME_SUFFIX}" \
			"Key=ProjectName,Value=${PROJECT}-${ENV}-${NAME_SUFFIX}" \
		--template-body "file://aws/pipeline/main.yaml"

## Creates a new CF stack
create-foundation: upload
	@aws cloudformation create-stack --stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" \
		--capabilities CAPABILITY_NAMED_IAM \
		--disable-rollback \
		--parameters \
			"ParameterKey=CidrBlock,ParameterValue=10.1.0.0/16" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.foundation" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=PublicFQDN,ParameterValue=${DOMAIN}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
			"ParameterKey=SubnetPrivateCidrBlocks,ParameterValue='10.1.11.0/24,10.1.12.0/24,10.1.13.0/24'" \
			"ParameterKey=SubnetPublicCidrBlocks,ParameterValue='10.1.1.0/24,10.1.2.0/24,10.1.3.0/24'" \
		--region ${REGION} \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${NAME_SUFFIX}" \
			"Key=ProjectName,Value=${PROJECT}-${ENV}-${NAME_SUFFIX}" \
		--template-body "file://aws/foundation/main.yaml"

## Create new CF App stack
create-app: upload-app
	@aws cloudformation create-stack --stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}" \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=AppName,ParameterValue=${APP}" \
			"ParameterKey=AppStackName,ParameterValue=${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}" \
			"ParameterKey=BuildArtifactsBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.build" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationStackName,ParameterValue=${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" \
			"ParameterKey=InfraDevBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.infradev" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=UserName,ParameterValue=${NAME_SUFFIX}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
		--region ${REGION} \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${NAME_SUFFIX}" \
			"Key=ProjectName,Value=${PROJECT}-${ENV}-${NAME_SUFFIX}" \
		--template-body "file://aws/app/main.yaml"


## Creates Foundation and Build DevOps Pipeline
update-pipeline: upload-pipeline
	@aws cloudformation update-stack --stack-name "${PROJECT}-${NAME_SUFFIX}-pipeline" \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=BuildArtifactsBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.build" \
			"ParameterKey=Environment,ParameterValue=all" \
			"ParameterKey=FoundationBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.foundation" \
			"ParameterKey=GithubBranch,ParameterValue=${GITHUB_BRANCH}" \
			"ParameterKey=GithubOAuthToken,ParameterValue=${GITHUB_OAUTH_TOKEN}" \
			"ParameterKey=GithubOwner,ParameterValue=${GITHUB_OWNER}" \
			"ParameterKey=GithubRepo,ParameterValue=${GITHUB_REPO}" \
			"ParameterKey=InfraDevBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.infradev" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=NameSuffix,ParameterValue=${NAME_SUFFIX}" \
		--region ${REGION} \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${NAME_SUFFIX}" \
			"Key=ProjectName,Value=${PROJECT}-${ENV}-${NAME_SUFFIX}" \
		--template-body "file://aws/pipeline/main.yaml"

## Updates existing Foundation CF stack
update-foundation: upload
	@aws cloudformation update-stack --stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=CidrBlock,ParameterValue=10.1.0.0/16" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.foundation" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=PublicFQDN,ParameterValue=${DOMAIN}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
			"ParameterKey=SubnetPrivateCidrBlocks,ParameterValue='10.1.11.0/24,10.1.12.0/24,10.1.13.0/24'" \
			"ParameterKey=SubnetPublicCidrBlocks,ParameterValue='10.1.1.0/24,10.1.2.0/24,10.1.3.0/24'" \
		--region ${REGION} \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${NAME_SUFFIX}" \
			"Key=ProjectName,Value=${PROJECT}-${ENV}-${NAME_SUFFIX}" \
		--template-body "file://aws/foundation/main.yaml" \


## Update existing App CF Stack
update-app: upload-app
	@aws cloudformation update-stack --stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}" \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=AppName,ParameterValue=${APP}" \
			"ParameterKey=AppStackName,ParameterValue=${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}" \
			"ParameterKey=BuildArtifactsBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.build" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationStackName,ParameterValue=${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" \
			"ParameterKey=InfraDevBucket,ParameterValue=awsrig.${PROJECT}.${NAME_SUFFIX}.infradev" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=UserName,ParameterValue=${NAME_SUFFIX}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
		--region ${REGION} \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${NAME_SUFFIX}" \
			"Key=ProjectName,Value=${PROJECT}-${ENV}-${NAME_SUFFIX}" \
		--template-body "file://aws/app/main.yaml"

## Print Foundation stack's status
status-foundation:
	@aws cloudformation describe-stacks \
		--query "Stacks[][StackStatus] | []" \
		--region ${REGION} \
		--stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" | jq

## Print app stack's outputs
outputs-foundation:
	@aws cloudformation describe-stacks \
		--query "Stacks[][Outputs] | []" \
		--region ${REGION} \
		--stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" | jq


## Print app stack's status
status-app:
	@aws cloudformation describe-stacks \
		--region ${REGION} \
		--stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}" \
		--query "Stacks[][StackStatus] | []" | jq


## Print app stack's outputs
outputs-app:
	@aws cloudformation describe-stacks \
		--region ${REGION} \
		--stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}" \
		--query "Stacks[][Outputs] | []" | jq



## Deletes the DevOps Pipeline CF stack
delete-pipeline:
	@if ${MAKE} .prompt-yesno message="Are you sure you wish to delete the Foundation Stack?"; then \
		aws cloudformation delete-stack --region ${REGION} --stack-name "${PROJECT}-${NAME_SUFFIX}-pipeline"; \
	fi

## Deletes the Foundation CF stack
delete-foundation:
	@if ${MAKE} .prompt-yesno message="Are you sure you wish to delete the Foundation Stack?"; then \
		aws cloudformation delete-stack --region ${REGION} --stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation"; \
	fi

## Deletes the App CF stack
delete-app:
	@if ${MAKE} .prompt-yesno message="Are you sure you wish to delete the App ${APP} Stack?"; then \
		aws cloudformation delete-stack --region ${REGION} --stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}"; \
	fi


package-pipeline:
	@[ -d .cfn-pkg ] || mkdir .cfn-pkg
	@aws cloudformation package \
		--output-template-file .cfn-pkg/aws/pipeline/packaged.yml \
		--region ${REGION} \
		--s3-bucket awsrig.${PROJECT}.${NAME_SUFFIX}.infradev \
		--template-file aws/pipeline/main.yml

## Upload Pipeline Templates to S3
# Uploads DevOps CD templates to the InfraDev bucket
# awsrig.${PROJECT}.${NAME_SUFFIX}.infradev/pipelines/
upload-pipeline:
	@sh ./bin/build-configs.sh
	@aws s3 cp config/${PROJECT}-${NAME_SUFFIX}-foundation.zip s3://awsrig.${PROJECT}.${NAME_SUFFIX}.infradev/pipeline/config/

## Upload CF Templates to S3
# Uploads foundation templates to the Foundation bucket
# awsrig.${PROJECT}.${NAME_SUFFIX}.foundation/${ENV}/templates/
upload:
	@aws s3 cp --recursive aws/foundation/ s3://awsrig.${PROJECT}.${NAME_SUFFIX}.foundation/dev/templates/
	@aws s3 cp --recursive aws/foundation/ s3://awsrig.${PROJECT}.${NAME_SUFFIX}.foundation/stg/templates/
	@aws s3 cp --recursive aws/foundation/ s3://awsrig.${PROJECT}.${NAME_SUFFIX}.foundation/prd/templates/


## Upload CF Templates for APP
# Note that these templates will be stored in your InfraDev Project **shared** bucket:
# awsrig.${PROJECT}.${NAME_SUFFIX}.infradev/${ENV}/templates/
upload-app:
	@aws s3 cp --recursive aws/app/ s3://awsrig.${PROJECT}.${NAME_SUFFIX}.infradev/${ENV}/templates/
	pwd=$(shell pwd)
	cd aws/app/ && zip templates.zip *.yaml
	cd ${pwd}
	@aws s3 cp aws/app/templates.zip s3://awsrig.${PROJECT}.${NAME_SUFFIX}.infradev/${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}/templates/
	rm -rf aws/app/templates.zip
	@aws s3 cp aws/app/service.yaml s3://awsrig.${PROJECT}.${NAME_SUFFIX}.infradev/${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}/templates/


store-ubuntu-ami:
	@sh ./bin/latest-ubuntu-ami.sh
	$(eval export UBUNTU_AMI_ID = $(shell cat .${REGION}_ubuntu_ami_id) )
	@echo "Ubuntu AMI ID for AWS region (${REGION}): ${AMI_ID}"
	@echo "(Stored this in .${REGION}_ubuntu_ami_id)"

store-rancher-ami:
	@sh ./bin/latest-rancher-ami.sh
	$(eval export RANCHER_AMI_ID = $(shell cat .${REGION}_rancher_ami_id) )
	@echo "Rancher AMI ID for AWS region (${REGION}): ${AMI_ID}"
	@echo "(Stored this in .${REGION}_rancher_ami_id)"

store-rancher-ecs-ami:
	@sh ./bin/latest-rancher-ecs-ami.sh
	$(eval export RANCHER_ECS_AMI_ID = $(shell cat .${REGION}_rancher_ecs_ami_id) )
	@echo "Rancher ECS AMI ID for AWS region (${REGION}): ${AMI_ID}"
	@echo "(Stored this in .${REGION}_rancher_ecs_ami_id)"



check-env:
ifndef NAME_SUFFIX
	$(error NAME_SUFFIX is undefined, should be in file .make)
endif
ifndef DOMAIN
	$(error DOMAIN is undefined, should be in file .make)
endif
ifndef EMAIL
	$(error EMAIL is undefined, should be in file .make)
endif
ifndef ENV
	$(error ENV is undefined, should be in file .make)
endif
ifndef KEY_NAME
	$(error KEY_NAME is undefined, should be in file .make)
endif
ifndef NAME_SUFFIX
	$(error NAME_SUFFIX is undefined, should be in file .make)
endif
ifndef PROFILE
	$(error PROFILE is undefined, should be in file .make)
endif
ifndef PROJECT
	$(error PROJECT is undefined, should be in file .make)
endif
ifndef REGION
	$(error REGION is undefined, should be in file .make)
endif
	@echo "All required ENV vars set"

## Print this help
help:
	@awk -v skip=1 \
		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
		 skip  { next } \
		 /^#/  { doc=doc "\n" substr($$0, 2); next } \
		 /:/   { sub(/:.*/, "", $$0); printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$0, doc_h, doc; skip=1 }' \
		${MAKEFILE_LIST}


.CLEAR=\x1b[0m
.BOLD=\x1b[01m
.RED=\x1b[31;01m
.GREEN=\x1b[32;01m
.YELLOW=\x1b[33;01m

# Re-usable target for yes no prompt. Usage: make .prompt-yesno message="Is it yes or no?"
# Will exit with error if not yes
.prompt-yesno:
	$(eval export RESPONSE="${shell read -t5 -n1 -p "${message} [Yy]: " && echo "$$REPLY" | tr -d '[:space:]'}")
	@case ${RESPONSE} in [Yy]) \
			echo "\n${.GREEN}[Continuing]${.CLEAR}" ;; \
		*) \
			echo "\n${.YELLOW}[Cancelled]${.CLEAR}" && exit 1 ;; \
	esac


.make:
	@touch .make
	@if ${MAKE} .prompt-yesno message="Want to interactively populate .make file?"; then \
		sh ./bin/build-dotmake.sh; \
	fi

.DEFAULT_GOAL := help
.PHONY: help
.PHONY: deps check-env get-ubuntu-ami .prompt-yesno
