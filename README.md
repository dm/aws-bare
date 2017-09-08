# AWS "Bare Metal" Rig  (BMR)

This repo creates a CloudFormation continuous delivery pipeline using only
AWS services only.

It's composed of a DevOps CD Pipeline, a Foundation VPC and an application ECS
cluster with it's own delivery pipeline.


## Services Used

 * AutoScaling (ECS)
 * CloudFormation
 * CodeBuild
 * CodeCommit
 * CodePipeline
 * ECR
 * ECS
 * Elastic LoadBalancer (V2)
 * _Github_
 * IAM / SecurityGroups
 * Route53
 * S3
 * VPC + multi-zone, public/private networking/routing, Internet Gateway, Nat Gateway


## Setup

### Dependencies

For using this repo you'll need:

 * AWS CLI, and credentials working: `brew install awscli && aws configure`
 * Setup `.make` for local settings

This can either be done by copying settings from the template `.make.example`
and save in a new file `.make` or done interactively through `make .make`:

```
APP = <Application name if you're doing more than Foundation stack>
DOMAIN = <Domain to use for Foundation>
EMAIL = <User contact e-mail>
ENV = <Environment i.e.: tst, dev, stg, prd>
GITHUB_BRANCH = <Branch for pipeline>
GITHUB_OAUTH_TOKEN = <Github OAuth access token>
GITHUB_OWNER = <Github user>
GITHUB_REPO = <Github repo name>
KEY_NAME = <EC2 SSH key name>
NAME_SUFFIX = <Your unique FirstLast name>
PROFILE = <AWS Profile Name>
PROJECT = <Project Name>
REGION = <AWS Region>
```

Confirm environment vars are properly set with `make check-env`

Run `make deps` to create required S3 buckets.

## Makefile Targets

  * Run `make create-pipeline` to start an AWS BMR Foundation DevOps Pipeline
  * Run `make create-foundation` to start an AWS BMR Foundation Stack

This is the Stack that will be shared by all management and services in an AWS Region.

  * Run `make status-foundation` to check status of the stack. (Should be `CREATE_COMPLETE`)
  * Check the outputs as well with `make outputs-foundation`
  * Run `make create-app`, same options for status: `make status-app` and outputs `make outputs-app`

To delete everything, in order:

  * Run `make delete-app` to delete the App stack
  * Run `make delete-foundation` to delete the Foundation stack
  * Run `make delete-pipeline` to delete the Devops Pipeline stack
