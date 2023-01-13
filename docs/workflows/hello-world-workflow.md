---
title: A Hello-world Workflow
date: 2023-01-13
---

# A Hello-world Workflow

The "Hello World" example uses an example hardware data, template, and workflow to show off some basic Tinkerbell functionality, and the interaction between a Provisioner and a Worker.
It uses the hello-world docker image as an example task that could be performed on a Worker as part of a workflow.

## Prerequisites

- You have a Provisioner up and running, with the Tinkerbell stack installed and configured.
  This can be done locally with Vagrant as an experimental environment, on Equinix Metal for a more robust setup, or installed on any other environment that you have configured.

- You have a Worker that has not yet been brought up, or can be restarted.

## Hardware Data

This example is intended to be environment agnostic, and assumes that you have a Worker machine as the intended target.
The workflow in this example is simple enough that you can use the [Minimal Hardware Data example] with your targeted Worker's MAC Address and/or IP Address substituted in.

## The `hello-world` Action Image

The workflow will have a single task that will have a single action.
Actions are stored as images in an image repository either locally or remotely.
For this example, pull down the `hello-world` image from Docker to host it locally in the Docker registry on the Provisioner.

```sh
docker pull hello-world
docker tag hello-world <registry-host>/hello-world
docker push <registry-host>/hello-world
```

This image doesn't have any instructions that the Worker will be able to perform, it's just an example to enable pushing a workflow out to the Worker when it comes up.

## The Hardware

Create a simple hardware YAML file like below, and tailor it to your particular setup - be that a VM target or maybe a consumer device you may test on.

The envorinment variable below will be specific to your environment - for example depending on the type of storage you have, it could be `/dev/sda` or `/dev/nvme0n1`

Key here is to recognize the `metadata.name` field value will be re-used in the subsequent workflow YAML to uniquely identify and recognize this machine. 
```yaml

apiVersion: "tinkerbell.org/v1alpha1"
kind: Hardware
metadata:
  name: mymachine1
spec:
  disks:
    - device: $DISK_DEVICE
  metadata:
    facility:
      facility_code: sandbox
    instance:
      hostname: "mymachine1"
      id: "$TINKERBELL_CLIENT_MAC"
      operating_system:
        distro: "ubuntu"
        os_slug: "ubuntu_20_04"
        version: "20.04"
  interfaces:
    - dhcp:
        arch: x86_64
        hostname: mymachine1
        ip:
          address: $TINKERBELL_CLIENT_IP
          gateway: $TINKERBELL_CLIENT_GW
          netmask: 255.255.255.0
        lease_time: 86400
        mac: $TINKERBELL_CLIENT_MAC
        name_servers:
          - 1.1.1.1
          - 8.8.8.8
        uefi: false
      netboot:
        allowPXE: true
        allowWorkflow: true
```

Once you are happy with your YAML file, issue the following onto your Tinkerbell K8s cluster:
```
kubectl -n tink-system apply -f [myhardwarefilename].yaml
```

## The Template

A template is a YAML file that lays out the series of tasks that you want to perform on the Worker after it boots up.
The template for this workflow contains the one task with single `hello-world` action.

Save this template as `hello-world-template.yaml`.

Execute `kubectl -n tink-system apply -f hello-world-template.yaml`

```yaml

apiVersion: "tinkerbell.org/v1alpha1"
kind: Template
metadata:
  name: hello_world_template
  namespace: tink-system
spec:
  data: |
    version: "0.1"
    name: hello_world_template
    global_timeout: 1800
    tasks:
      - name: "hello world"
        image: hello-world
        timeout: 60
```

## The Workflow

Create a workflow YAML file like the following. This is a simple file, the contents should be readily understandable. 
```yaml

apiVersion: "tinkerbell.org/v1alpha1"
kind: Workflow
metadata:
  name: helloworldWf1
  namespace: tink-system
spec:
  templateRef: hello_world_template
  hardwareRef: mymachine1
  hardwareMap:
    device_1: $TINKERBELL_CLIENT_MAC

```
Now apply this file, like similar yamls before by:
```yaml

kubectl -n tink-system apply -f [myworkflowfilename].yaml
```
## Workflow Execution

You can now boot up or restart your Worker and a few things are going to happen:

- First, the Worker will iPXE boot into an Alpine Linux distribution running in memory
- Second, the Worker will call back to the Provisioner to check for it's workflow.
- Third, The Provisioner will push the workflow to the Worker for it to execute.

While the workflow execution does not have much effect on the state of the Worker, you can check that the workflow was successfully executed from the `kubectl -n tink-system get workflow helloworldWf1` command.

If you reboot the Worker at this point, it will again PXE boot, since no alternate operating system was installed as part of the `hello-world` workflow.

[minimal hardware data example]: /hardware-data/#the-minimal-hardware-data
