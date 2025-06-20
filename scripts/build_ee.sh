#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
echo "this_dir: ${this_dir}"
echo "root_dir: ${root_dir}"

tag=${EE_TAG}
echo "tag: ${tag}"
galaxy_token=${ANSIBLE_GALAXY_TOKEN}

python -m venv ${HOME}/.venv/adt
source ${HOME}/.venv/adt/bin/activate
trap deactivate EXIT
pip install --upgrade pip
pip install ansible-dev-tools

ansible-builder create --output-filename Containerfile \
    --file ${root_dir}/ee/ee.yaml --context ${root_dir}/ee \
    --verbosity 3

podman build -t ${tag} \
    --build-arg ANSIBLE_GALAXY_SERVER_LIST=automation_hub_certified,automation_hub_validated,upstream_galaxy \
    --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_CERTIFIED_URL=https://console.redhat.com/api/automation-hub/content/published/ \
    --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_CERTIFIED_AUTH_URL=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token \
    --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_CERTIFIED_TOKEN=${galaxy_token} \
    --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_VALIDATED_URL=https://console.redhat.com/api/automation-hub/content/validated/ \
    --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_VALIDATED_AUTH_URL=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token \
    --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_VALIDATED_TOKEN=${galaxy_token} \
    --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN=${galaxy_token} \
    --build-arg ANSIBLE_GALAXY_SERVER_UPSTREAM_GALAXY_URL=https://galaxy.ansible.com \
        ${root_dir}/ee/

podman push ${tag}
