## To run Factory Setup

- Create and activate a venv
- Install ansible-dev-tools: `pip install ansible-dev-tools`
    - run `adt --version` to list all available tools
- Get a token for Red Hat's Automation Hub (Galaxy) from <https://console.redhat.com/ansible/automation-hub/token> and set in ANSIBLE_GALAXY_TOKEN
- Subscribe the build system to Red Hat, required for `openshift-clients` package:

    ```bash
    activation_key_name=${activation_key_name}
    organization_id=${organization_id}
    sudo subscription-manager register --activationkey ${activation_key_name} --org ${organization_id}
    ```

- Run a build for the execution environment

    ```bash
    this_dir=$(pwd)
    tag=quay.io/${USER}/ovmf:latest
    ANSIBLE_GALAXY_TOKEN=${ANSIBLE_GALAXY_TOKEN}

    ansible-builder create --output-filename Containerfile --file ${this_dir}/ee/ee.yaml --context ${this_dir}/ee

    podman build -t ${tag} \
        --build-arg ANSIBLE_GALAXY_SERVER_LIST=automation_hub_certified,automation_hub_validated,upstream_galaxy \
        --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_CERTIFIED_URL=https://console.redhat.com/api/automation-hub/content/published/ \
        --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_CERTIFIED_AUTH_URL=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token \
        --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_CERTIFIED_TOKEN=${ANSIBLE_GALAXY_TOKEN} \
        --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_VALIDATED_URL=https://console.redhat.com/api/automation-hub/content/validated/ \
        --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_VALIDATED_AUTH_URL=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token \
        --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_VALIDATED_TOKEN=${ANSIBLE_GALAXY_TOKEN} \
        --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN=${ANSIBLE_GALAXY_TOKEN} \
        --build-arg ANSIBLE_GALAXY_SERVER_UPSTREAM_GALAXY_URL=https://galaxy.ansible.com \
        ./ee/

    podman push ${tag}
    ```

- Copy and update secrets in `inventory.template.yml` to `inventory.yml`
- Run the playbook:
    ```bash
    tag=quay.io/${USER}/ovmf:latest

    ansible-navigator run \
        --eei=${tag} \
        --mode=stdout \
        --pp=missing \
        /usr/share/ansible/collections/ansible_collections/infra/openshift_virtualization_migration/playbooks/migration_factory_aap.yml \
        --pae false \
        --inventory inventory.yml \
        --inventory inventory-base.yml \
        -e openshift_host=$(oc whoami --show-server) \
        -e openshift_temporary_api_key=$(oc whoami -t)
    ```

## Resources
- https://github.com/juliovp01/etx-virt_delivery
- https://github.com/ansiblejunky/ansible-execution-environment
- https://pages.consulting.redhat.com/redhat-cop/openshift-virtualization-migration/documentation/guides/home.html
- https://gitlab.consulting.redhat.com/redhat-cop/openshift-virtualization-migration
- https://source.redhat.com/projects_and_programs/ansible_for_openshift_virtualization_migration