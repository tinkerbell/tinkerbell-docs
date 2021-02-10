---
title: Templates
date: 2020-08-03
---

# Templates

A Template is a YAML file that defines the source of a Workflow by declaring one or more _tasks_.
The tasks are executed sequentially, in the order in which they are declared.

Each task consists of one or more _actions_.
Each action contains an image to be executed as part of a workflow, identified by the `image` field.
You can create any script, app, or other set of instructions to be an action image by containerizing it and pushing it into either the local Docker registry included in the Tinkerbell stack or an external image repository.

Here is a sample template:

```yaml
version: "0.1"
name: ubuntu_provisioning
global_timeout: 6000
tasks:
  - name: "os-installation"
    worker: "{{.device_1}}"
    volumes:
      - /dev:/dev
      - /dev/console:/dev/console
      - /lib/firmware:/lib/firmware:ro
    environment:
      MIRROR_HOST: <MIRROR_HOST_IP>
    actions:
      - name: "disk-wipe"
        image: disk-wipe
        timeout: 90
      - name: "disk-partition"
        image: disk-partition
        timeout: 600
        environment:
          MIRROR_HOST: <MIRROR_HOST_IP>
        volumes:
          - /statedir:/statedir
      - name: "install-root-fs"
        image: install-root-fs
        timeout: 600
      - name: "install-grub"
        image: install-grub
        timeout: 600
        volumes:
          - /statedir:/statedir
```

The `volumes` field contains the volume mappings between the host machine and the docker container where your images are running.

The `environment` field is used to pass environment variables to the images.

Each action can have its own volumes and environment variables.
Any entry at an action will overwrite the value defined at the task level.
For example, in the above template the `MIRROR_HOST` environment variable defined at action `disk-partition` will overwrite the value defined at task level.
The other actions will receive the original value defined at the task level.

The timeout defines the amount of time to wait for an action to execute and is in seconds.

A hardware device, such as a Worker's MAC address, is specified in template as keys.

```
{{.device_1}}
{{.device_2}}
```

Keys can only contain _letters_, _numbers_ and _underscores_.
These keys are evaluated during workflow creation, being passed in as an JSON argument to `tink workflow create`.

Templates are each stored as blobs in the database; they are later parsed during the creation of a workflow.

## Template CLI Commands

```
  create      Create a template in the database.
  delete      Delete a template from the database.
  get         Get a template by ID.
  list        List all templates in the database.
  update      Update an existing template.
```

`tink template --help` - Displays the available commands and their usage for `tink template`.
