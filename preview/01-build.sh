#!/bin/bash

## run this script in the Jekyll docs directory
# cd ../docs
SCRIPT_DIR=$(cd $(dirname $0); pwd)  # absolute path of the script directory
cd ${SCRIPT_DIR}/../docs/

DOCKERFILE="${SCRIPT_DIR}/Dockerfile"
podman build -t jekyll-local:1.1 -f "${DOCKERFILE}" .
