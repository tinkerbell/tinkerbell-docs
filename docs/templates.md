---
title: Templates
date: 2023-01-13
---

# Templates

A Template is a YAML file that defines the source of a Workflow by declaring one or more _tasks_.
The tasks are executed sequentially, in the order in which they are declared.

Each task consists of one or more [action].
Each action contains an image to be executed as part of a workflow, identified by the `image` field.
You can create any script, app, or other set of instructions to be an action image by containerizing it and pushing it into either the local Docker registry included in the Tinkerbell stack or an external image repository.

Consider Templates to be orthogonal to Hardware YAML definitions. Templates should be agnostic to any hardware information, rather they could be reused across a range of selected hardware. So, while it is possible to insert hardware specific information in Template files - like specific IP info to write to rootfs - it is highly advisable not to. Instead use helm templating mechanisms to dynamically populate information as it is applied to your Tinkerbell K8s deployment. `"{{.device_1}}"` is one such example below.

Here is a sample template:

```yaml
apiVersion: "tinkerbell.org/v1alpha1"
kind: Template
metadata:
  name: debian
  namespace: default
spec:
  data: |
    version: "0.1"
    name: debian
    global_timeout: 1800
    tasks:
      - name: "os-installation"
        worker: "{{.device_1}}"
        volumes:
          - /dev:/dev
          - /dev/console:/dev/console
          - /lib/firmware:/lib/firmware:ro
        actions:
          - name: "stream-debian-image"
            image: quay.io/tinkerbell-actions/image2disk:v1.0.0
            timeout: 600
            environment:
              DEST_DISK: /dev/nvme0n1
              # Hegel IP
              IMG_URL: "http://10.1.1.11:8080/debian-10-openstack-amd64.raw.gz"
              COMPRESSED: true
          - name: "add-tink-cloud-init-config"
            image: writefile:v1.0.0
            timeout: 90
            environment:
              DEST_DISK: /dev/nvme0n1p1
              FS_TYPE: ext4
              DEST_PATH: /etc/cloud/cloud.cfg.d/10_tinkerbell.cfg
              UID: 0
              GID: 0
              MODE: 0600
              DIRMODE: 0700
              CONTENTS: |
                datasource:
                  Ec2:
                    # Hegel IP
                    #metadata_urls: ["http://10.1.1.11:50061"]
                    strict_id: false
                system_info:
                  default_user:
                    name: tink
                    groups: [wheel, adm, sudo]
                    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
                    shell: /bin/bash
                users:
                - name: tink
                  sudo: ["ALL=(ALL) NOPASSWD:ALL"]
                warnings:
                  dsid_missing_source: off
          - name: "add-tink-cloud-init-ds-config"
            image: writefile:v1.0.0
            timeout: 90
            environment:
              DEST_DISK: /dev/nvme0n1p1
              FS_TYPE: ext4
              DEST_PATH: /etc/cloud/ds-identify.cfg
              UID: 0
              GID: 0
              MODE: 0600
              DIRMODE: 0700
              CONTENTS: |
                datasource: Ec2
          - name: "kexec-debian"
            image: quay.io/tinkerbell-actions/kexec:v1.0.1
            timeout: 90
            pid: host
            environment:
              BLOCK_DEVICE: /dev/nvme0n1p1
              FS_TYPE: ext4
```

The `metadata.name` field contains a unique identifier for a specific template. This field is what is presented from any `"kubectl get template"` command identifying provisioned templates and used to select a template for deletion.

`metadata.namespace` should be updated to the namespace where the Tinkerbell stack is running.

The `tasks` definition contains an array of actions, each starting with a human readable `-name:` field, to be run when invoked. Actions are described in detail elsewhere, however briefly each action is essentially a container image deployed and run on the target machine to perform a very specific task. Hence, every action can have its own volumes and environment variables.
Any entry at an action will overwrite the value defined at the task level.
The other actions will receive the original value defined at the task level.

The timeout defines the amount of time to wait for an action to execute and is in seconds.

A hardware device, such as a Worker's MAC address, is specified in template as keys.

```text
{{.device_1}}
{{.device_2}}
```

Keys can only contain _letters_, _numbers_ and _underscores_.
These keys are evaluated during workflow creation.

## Template Management Commands

Tinkerbell is provisioned with a template via stock k8s mechanism. What follows in sequence is an example of a template being created, inspected and removed.

```

kubectl -n tink-system apply -f mytemplate.yaml
kubectl -n tink-system get template
kubectl -n tink-system delete template debian

```

[action]: /actions/action-architecture
