---
title: A Hello-world Workflow
date: 2020-07-10
---

# A Hello-world Workflow

The "Hello World" example uses an example hardware data, template, and workflow to show off some basic Tinkerbell functionality, and the interaction between a Provisioner and a Worker. It uses the hello-world docker image as an example task that could be performed on a Worker as part of a workflow.

## Prerequisites

- You have a Provisioner up and running, with the Tinkerbell stack installed and configured. This can be done locally with Vagrant as an experimental environment, on Equinix Metal for a more robust setup, or installed on any other environment that you have configured.

- You have a Worker that has not yet been brought up, or can be restarted.

## Hardware Data

This example is intended to be environment agnostic, and assumes that you have a Worker machine as the intended target. The workflow in this example is simple enough that you can use the [Minimal Hardware Data example](/hardware-data/#the-minimal-hardware-data) with your targeted Worker's MAC Address and/or IP Address substituted in.

## The `hello-world` Action Image

The workflow will have a single task that will have a single action. Actions are stored as images in an image repository either locally or remotely. For this example, pull down the `hello-world` image from Docker to host it locally in the Docker registry on the Provisioner.

```bash
docker pull hello-world
docker tag hello-world <registry-host>/hello-world
docker push <registry-host>/hello-world
```

This image doesn't have any instructions that the Worker will be able to perform, it's just an example to enable pushing a workflow out to the Worker when it comes up.

## The Template

A template is a YAML file that lays out the series of tasks that you want to perform on the Worker after it boots up. The template for this workflow contains the one task with single `hello-world` action. The worker field contains a reference to `device_1` which will be substituted with either the MAC Address or the IP Address of your Worker when you run the `tink workflow create` command in the next step.

Save this template as `hello-world.tmpl`.

```yaml
version: "0.1"
name: hello_world_workflow
global_timeout: 600
tasks:
  - name: "hello world"
    worker: "{{.device_1}}"
    actions:
      - name: "hello_world"
        image: hello-world
        timeout: 60
```

## The Workflow

If you haven't already, be sure to have

- Pushed the Worker's hardware data to the database with `tink hardware push`.
- Created the template in the database with `tink template create`.

You can now use the hardware data and the template to create a workflow. You need two pieces of information. The MAC Address or IP Address of your Worker as specified in the hardware data and the Template ID that is returned from the `tink template create` command.

```bash
tink workflow create -t <template_id> -r '{"device_1": "<MAC address/IP address>"}'
```

## Workflow Execution

You can now boot up or restart your Worker and a few things are going to happen:

- First, the Worker will iPXE boot into an Alpine Linux distribution running in memory
- Second, the Worker will call back to the Provisioner to check for it's workflow.
- Third, The Provisioner will push the workflow to the Worker for it to execute.

While the workflow execution does not have much effect on the state of the Worker, you can check that the workflow was successfully executed from the `tink workflow events` command.

```
tink workflow events <ID>
>
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
| WORKER ID                            | TASK NAME   | ACTION NAME | EXECUTION TIME | MESSAGE                         |      ACTION STATUS |
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
| ce2e62ed-826f-4485-a39f-a82bb74338e2 | hello world | hello_world |              0 | Started execution               | ACTION_IN_PROGRESS |
| ce2e62ed-826f-4485-a39f-a82bb74338e2 | hello world | hello_world |              0 | Finished Execution Successfully |     ACTION_SUCCESS |
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
```

If you reboot the Worker at this point, it will again PXE boot, since no alternate operating system was installed as part of the `hello-world` workflow.
