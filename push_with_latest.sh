#!/usr/bin/env bash

source $(dirname $0)/common.sh || echo "$0: Failed to source common.sh"

processCliArgs $@

install_aws_cli() {
  pip install --upgrade pip
  pip install --upgrade awscli
}

# Check whether to install aws clis
which aws &>/dev/null || install_aws_cli

echo "Set AWS region"
aws configure set default.region ${ARGS[--aws_region]}

echo "Login to ECR"
$(aws ecr get-login --no-include-email)

echo "Verify repository exists"
aws ecr describe-repositories --repository-names ${ARGS[--service_name]}} &>/dev/null || \
#aws ecr create-repository --repository-name ${ARGS[--service_name]}

echo "Tag image with version"
docker tag ${ARGS[--service_name]}:${ARGS[--image_version]} \
  ${ARGS[--ecr_endpoint]}/${ARGS[--service_name]}:${ARGS[--image_version]}

echo "Tag image with latest"
docker tag ${ARGS[--service_name]}:${ARGS[--image_version]} \
  ${ARGS[--ecr_endpoint]}/${ARGS[--service_name]}:latest

echo "Pushing images to ECR"
docker push ${ARGS[--ecr_endpoint]}/${ARGS[--service_name]}:${ARGS[--image_version]}
docker push ${ARGS[--ecr_endpoint]}/${ARGS[--service_name]}:latest
