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

- Create an EE per the instructions above
- Copy and update secrets in `inventory/inventory.template.yml` to `inventory/inventory.yml`
- Run the `migration_factory_aap` playbook using the EE created above, see `./scripts/configure_aap.sh`

## Run a Migration

- Use the job template to create a provider for the VMware source (aka "target")
- Use the job template to create mappings for the VMware source
- Use the job template to create a migration plan, providing the following vars:

```yaml
mtv_migrate_migration_request:
    mtv_namespace: openshift-mtv
    target_namespace: vms
    source: vmware
    source_namespace: openshift-mtv
    source_type: vsphere
    destination: host
    destination_namespace: openshift-mtv
    destination_type: openshift
    network_map: vmware-host
    network_map_namespace: openshift-mtv
    storage_map: vmware-host
    storage_map_namespace: openshift-mtv
    plan_name: first-migration

    verify_plans_ready: true
    start_migration: true
    # split_plans: false
    # vms_per_plan: 10
    # verify_migrations_complete: false
    vms:
        - path: "/SDDC-Datacenter/vm/Workloads/sandbox-zm9fb/rhel-transfer01"
    # folders:
    #     - path: "/SDDC-Datacenter/vm/Workloads/sandbox-zm9fb"
```

## Resources

- https://github.com/juliovp01/etx-virt_delivery
- https://github.com/ansiblejunky/ansible-execution-environment
- https://pages.consulting.redhat.com/redhat-cop/openshift-virtualization-migration/documentation/guides/home.html
- https://gitlab.consulting.redhat.com/redhat-cop/openshift-virtualization-migration
- https://source.redhat.com/projects_and_programs/ansible_for_openshift_virtualization_migration