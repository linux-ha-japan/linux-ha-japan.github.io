#!/bin/bash

## run this script in the Jekyll docs directory
# cd ../docs
SCRIPT_DIR=$(cd $(dirname $0); pwd)  # absolute path of the script directory
cd ${SCRIPT_DIR}/../docs/

podman run -it --rm -v .:/srv/jekyll:Z -p 4000:4000 localhost/jekyll-local:1.0
