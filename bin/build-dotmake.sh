#!/bin/bash

echo 'Please fill in the config settings to store in your .make'
echo
read -p 'Application: ' app
read -p 'Domain: ' domain
read -p 'Your e-mail: ' email
read -p 'Environment (tst, dev, stg, prd): ' env
read -p 'Github branch: ' github_branch
read -p 'Github OAuth token: ' github_token
read -p 'Github username: ' github_user
read -p 'Github repo: ' github_repo
read -p 'AWS SSH keyname: ' keyname
read -p 'Your name suffix (firstlastname): ' name_suffix
read -p 'AWS Profile: ' profile
read -p 'Project: ' project
read -p 'Repository Name: ' repo
read -p 'Repository Branch: ' repo_branch
read -p 'Repository OAuth token: ' repo_token
read -p 'AWS region: ' region
read -p 'Subdomain: ' subdomain
echo

cat << EOF > .make
APP = ${app}
DOMAIN = ${domain}
EMAIL = ${email}
ENV = ${env}
GITHUB_BRANCH = ${github_branch}
GITHUB_OAUTH_TOKEN = ${github_token}
GITHUB_OWNER = ${github_user}
GITHUB_REPO = ${github_repo}
KEY_NAME = ${keyname}
NAME_SUFFIX = ${name_suffix}
PROFILE = ${profile}
PROJECT = ${project}
REPO = ${repo}
REPO_BRANCH = ${repo_branch}
REPO_TOKEN = ${repo_token}
REGION = ${region}
SUBDOMAIN = ${subdomain}
EOF

echo 'Saved .make!'
echo
