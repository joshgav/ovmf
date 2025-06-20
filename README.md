# Use the OpenShift Virtualization Migration Factory

This repo shows how to use the OpenShift Virtualization Migration collection.

## Build an Execution Environment

Follow these steps to build an execution environment ready to run Migration Factory tasks.

- Copy `template.env` to `.env` and set secrets in its environment variables.
    - Get ANSIBLE_GALAXY_TOKEN from <https://console.redhat.com/ansible/automation-hub/token>
    - Get RHEL_ACTIVATION_KEY and RHEL_ORGANIZATION_ID from <https://console.redhat.com/insights/connector/activation-keys>
    - Set EE_TAG to the image tag to be used for the EE, e.g., `quay.io/joshgav/ovmf:latest`
- Create and activate a venv and `pip install ansible-dev-tools` within it
- Subscribe the system which will build the EE to Red Hat, required for `openshift-clients` package:
    ```bash
    sudo dnf install subscription-manager
    sudo subscription-manager register --activationkey ${RHEL_ACTIVATION_KEY} --org ${RHEL_ORGANIZATION_ID}
    ```
- Login to the registry where the EE image will be stored, e.g., `podman login quay.io/joshgav`
- Run a build and push for the execution environment: `./scripts/build_ee.sh`

## To deploy content to an AAP instance

- Copy and update secrets in `inventory/inventory.template.yml` to `inventory/inventory.yml`
- Run the playbook in the `adt` venv created above:
    ```bash
    tag=${EE_TAG}
    source ${HOME}/.venv/adt/bin/activate
    trap deactivate EXIT

    ansible-navigator run \
        --eei=${tag} \
        --mode=stdout \
        --pp=missing \
        /usr/share/ansible/collections/ansible_collections/infra/openshift_virtualization_migration/playbooks/migration_factory_aap.yml \
        --pae false \
        --inventory inventory/inventory.yml \
        --inventory inventory/inventory-base.yml \
        -e openshift_host=$(oc whoami --show-server) \
        -e openshift_temporary_api_key=$(oc whoami -t)
    ```

## Resources

- https://github.com/juliovp01/etx-virt_delivery
- https://github.com/ansiblejunky/ansible-execution-environment
- https://pages.consulting.redhat.com/redhat-cop/openshift-virtualization-migration/documentation/guides/home.html
- https://gitlab.consulting.redhat.com/redhat-cop/openshift-virtualization-migration
- https://source.redhat.com/projects_and_programs/ansible_for_openshift_virtualization_migration