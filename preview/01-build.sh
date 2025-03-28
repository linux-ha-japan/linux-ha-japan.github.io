#!/bin/bash

## run this script in the Jekyll docs directory
# cd ../docs
SCRIPT_DIR=$(cd $(dirname $0); pwd)  # absolute path of the script directory
cd ${SCRIPT_DIR}/../docs/

podman run -it --rm -v .:/srv/jekyll:Z -e GEM_HOME=/srv/jekyll/vendor -e JEKYLL_ROOTLESS=1 docker.io/jekyll/jekyll:4.2.2 bundle install
