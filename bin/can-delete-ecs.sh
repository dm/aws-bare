#!/bin/bash

# Will echo (0) if ECS repo can be deleted
# Or (1+) can't be deleted, print number of docker images stored

: ${PROJECT?"Need to set PROJECT env var"}
: ${ENV?"Need to set ENV env var"}
: ${NAME_SUFFIX?"Need to set NAME_SUFFIX env var"}
: ${APP?"Need to set APP env var"}

export ECR_REPO=$(echo "${PROJECT}-${ENV}-${NAME_SUFFIX}-app-${APP}-ecr-repo")
export ECR_REPO_EXISTS=$(aws ecr list-images --repository-name "${ECR_REPO}" 2>/dev/null || echo 0)

if [[ $ECR_REPO_EXISTS != "0" ]]; then
  export ECR_COUNT=$(aws ecr list-images --repository-name "${ECR_REPO}" 2>/dev/null | jq -r '.imageIds | length | select (.!=0|0)')
  if [[ "${ECR_COUNT}" != "0" ]]; then
    # Non empty repo, can't be deleted!
    echo ${ECR_COUNT}
    exit 0
  fi
fi
echo 0
