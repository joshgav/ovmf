#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f ${root_dir}/.env ]]; then source ${root_dir}/.env; fi
if [[ -f ${this_dir}/.env ]]; then source ${this_dir}/.env; fi
echo "this_dir: ${this_dir}"
echo "root_dir: ${root_dir}"

tag=${EE_TAG}
echo "tag: ${tag}"

python -m venv ${HOME}/.venv/adt
source ${HOME}/.venv/adt/bin/activate
trap deactivate EXIT
pip install --upgrade pip
pip install ansible-dev-tools

ansible-navigator run \
    --eei=${tag} \
    --mode=stdout \
    --pp=always \
    /usr/share/ansible/collections/ansible_collections/infra/openshift_virtualization_migration/playbooks/migration_factory_aap.yml \
    --pae false \
    --inventory inventory/inventory.yml \
    --inventory inventory/inventory-base.yml
