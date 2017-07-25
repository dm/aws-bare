include .make

export APP ?= appname
export DOMAIN ?= example.tld
export EMAIL ?= user@example.com
export ENV ?= dev
export KEY_NAME ?= ""
export NAME_SUFFIX ?= myrig-test-bucket
export PROFILE ?= default
export PROJECT ?= projectname
export RDS_ROOT_PASSWORD ?= $(shell cat ~/.myrig.rds_root_password)
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
	@./bin/destroy-deps.sh

## Creates Foundation and Build

## Creates a new CF stack
create-foundation: upload
	@aws cloudformation create-stack --stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" \
                --region ${REGION} \
		--template-body "file://aws/foundation/main.yaml" \
		--disable-rollback \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=CidrBlock,ParameterValue=10.1.0.0/16" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationBucket,ParameterValue=myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.foundation" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=PublicFQDN,ParameterValue=${DOMAIN}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
			"ParameterKey=SubnetPrivateCidrBlocks,ParameterValue='10.1.11.0/24,10.1.12.0/24,10.1.13.0/24'" \
			"ParameterKey=SubnetPublicCidrBlocks,ParameterValue='10.1.1.0/24,10.1.2.0/24,10.1.3.0/24'" \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${NAME_SUFFIX}" \
			"Key=ProjectName,Value=${PROJECT}-${ENV}-${NAME_SUFFIX}"

## Create new CF App stack
create-app: upload-app
	@aws cloudformation create-stack --stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}" \
                --region ${REGION} \
                --disable-rollback \
		--template-body "file://aws/app/main.yaml" \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=AppName,ParameterValue=${APP}" \
			"ParameterKey=AppStackName,ParameterValue=${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}" \
			"ParameterKey=BuildArtifactsBucket,ParameterValue=myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.build" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationStackName,ParameterValue=${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" \
			"ParameterKey=InfraDevBucket,ParameterValue=myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=RepositoryName,ParameterValue=${REPO}" \
			"ParameterKey=RepositoryBranch,ParameterValue=${REPO_BRANCH}" \
			"ParameterKey=RepositoryAuthToken,ParameterValue=${REPO_TOKEN}" \
			"ParameterKey=UserName,ParameterValue=${NAME_SUFFIX}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
			"ParameterKey=EcsInstanceType,ParameterValue=t2.small" \
			"ParameterKey=SshKeyName,ParameterValue=${KEY_NAME}" \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${NAME_SUFFIX}" \
			"Key=ProjectName,Value=${PROJECT}-${ENV}-${NAME_SUFFIX}"


## Updates existing Foundation CF stack
update-foundation: upload
	@aws cloudformation update-stack --stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" \
                --region ${REGION} \
		--template-body "file://aws/foundation/main.yaml" \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=CidrBlock,ParameterValue=10.1.0.0/16" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationBucket,ParameterValue=myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.foundation" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=PublicFQDN,ParameterValue=${DOMAIN}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
			"ParameterKey=SubnetPrivateCidrBlocks,ParameterValue='10.1.11.0/24,10.1.12.0/24,10.1.13.0/24'" \
			"ParameterKey=SubnetPublicCidrBlocks,ParameterValue='10.1.1.0/24,10.1.2.0/24,10.1.3.0/24'" \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${NAME_SUFFIX}" \
			"Key=ProjectName,Value=${PROJECT}-${ENV}-${NAME_SUFFIX}"


## Update existing App CF Stack
update-app: upload-app
	@aws cloudformation update-stack --stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}" \
                --region ${REGION} \
		--template-body "file://aws/app/main.yaml" \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			"ParameterKey=AppName,ParameterValue=${APP}" \
			"ParameterKey=AppStackName,ParameterValue=${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}" \
			"ParameterKey=BuildArtifactsBucket,ParameterValue=myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.build" \
			"ParameterKey=Environment,ParameterValue=${ENV}" \
			"ParameterKey=FoundationStackName,ParameterValue=${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" \
			"ParameterKey=InfraDevBucket,ParameterValue=myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev" \
			"ParameterKey=ProjectName,ParameterValue=${PROJECT}" \
			"ParameterKey=RepositoryName,ParameterValue=${REPO}" \
			"ParameterKey=RepositoryBranch,ParameterValue=${REPO_BRANCH}" \
			"ParameterKey=RepositoryAuthToken,ParameterValue=${REPO_TOKEN}" \
			"ParameterKey=UserName,ParameterValue=${NAME_SUFFIX}" \
			"ParameterKey=Region,ParameterValue=${REGION}" \
			"ParameterKey=EcsInstanceType,ParameterValue=t2.small" \
			"ParameterKey=SshKeyName,ParameterValue=${KEY_NAME}" \
		--tags \
			"Key=Email,Value=${EMAIL}" \
			"Key=Environment,Value=${ENV}" \
			"Key=Owner,Value=${NAME_SUFFIX}" \
			"Key=ProjectName,Value=${PROJECT}-${ENV}-${NAME_SUFFIX}"

## Print Foundation stack's status
status-foundation:
	@aws cloudformation describe-stacks \
                --region ${REGION} \
		--stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" \
		--query "Stacks[][StackStatus] | []" | jq

## Print app stack's outputs
outputs-foundation:
	@aws cloudformation describe-stacks \
                --region ${REGION} \
		--stack-name "${PROJECT}-${ENV}-${NAME_SUFFIX}-foundation" \
		--query "Stacks[][Outputs] | []" | jq


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

## Upload CF Templates to S3
# Uploads foundation templates to the Foundation bucket
# myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.foundation/${ENV}/templates/
upload:
	@aws s3 cp --recursive aws/foundation/ s3://myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.foundation/${ENV}/templates/


## Upload CF Templates for APP
# Note that these templates will be stored in your InfraDev Project **shared** bucket:
# myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev/${ENV}/templates/
upload-app:
	@aws s3 cp --recursive aws/app/ s3://myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev/${ENV}/templates/
	pwd=$(shell pwd)
	cd aws/app/ && zip templates.zip *.yaml
	cd ${pwd}
	@aws s3 cp aws/app/templates.zip s3://myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev/${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}/templates/
	rm -rf aws/app/templates.zip
	@aws s3 cp aws/app/service.yaml s3://myrig.${PROJECT}.${NAME_SUFFIX}.${REGION}.infradev/${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}/templates/


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
ifndef RDS_ROOT_PASSWORD
	$(error RDS_ROOT_PASSWORD is undefined, should be in file .make)
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
	@bin/build-dotmake.sh

.DEFAULT_GOAL := help
.PHONY: help
.PHONY: deps check-env get-ubuntu-ami .prompt-yesno
