#!/bin/bash

# replaces {{ lhajp_resource_url }} links to the local resources for preview

## run this script in the Jekyll docs directory
# cd ../docs
SCRIPT_DIR=$(cd $(dirname $0); pwd)  # absolute path of the script directory
cd ${SCRIPT_DIR}/../docs/

create_resources_symlink() {
    while sleep 1; do
        if [ -d ./_site ]; then
            if [ ! -e ./_site/resources ]; then
                ln -s ../../resources ./_site/resources
            fi
	fi
    done
}

trap "kill 0" EXIT
create_resources_symlink &

podman run -it --rm -v .:/srv/jekyll:Z -v ../resources:/srv/resources:Z -p 4000:4000 localhost/jekyll-local:1.0 bundle exec jekyll serve --force_polling --host 0.0.0.0 --config _config.yml,_config_preview.yml
