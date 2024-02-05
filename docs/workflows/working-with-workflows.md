---
title: Working with Workflows
date: 2020-07-28
---

# Working with Workflows

A workflow is the complete set of operations to be run on a Worker.
It consists of two building blocks: a Worker's [hardware data] and a [template].
Workflows are immutable.
Updating a template or hardware data does not update existing workflows.

## Creating a Workflow

You create a workflow with the `tink workflow create` command, which takes a template ID and a JSON object that identifies the Worker, and combines them into a workflow.
The workflow is stored in the database on the Provisioner and returns a workflow ID.

For example,

```sh
tink workflow create \
    -t 75ab8483-6f42-42a9-a80d-a9f6196130df \
    -r '{"device_1":"08:00:27:00:00:01"}'
Created Workflow:  a8984b09-566d-47ba-b6c5-fbe482d8ad7f
```

The template ID is `75ab8483-6f42-42a9-a80d-a9f6196130df`.
The MAC address of the Worker is `08:00:27:00:00:01`, which should match the MAC address of hardware data that you have already created to identify that Worker.
It is mapped to `device_1`, which is where the MAC address will be substituted into the template when the workflow is created.

After creating a workflow, you can retrieve it from the database by ID with `tink workflow get`.
This is particularly useful to check to see that the MAC address or IP Address of the Worker was correctly substituted when you created the workflow.

```sh
tink workflow get a8984b09-566d-47ba-b6c5-fbe482d8ad7f
version: "0.1"
name: hello_world_workflow
global_timeout: 600
tasks:
  - name: "hello world"
    worker: "08:00:27:00:00:01"
    actions:
      - name: "hello_world"
        image: hello-world
        timeout: 60
```

In addition, you can list all the workflows stored in the database with `tink workflow list`.
Delete a workflow with `tink workflow delete`.

## Workflow Execution

On the first boot, the Worker is PXE booted, asks Boots for it's IP address, and loads into OSIE.
It then asks the `tink-server` for workflows that match its MAC or IP address.
Those workflows are then executed onto the Worker.

![Architecture]

If there are no workflows defined for the Worker, the Provisioner will ignore the Worker's request.
If as a part of the workflow, a new OS is installed and completes successfully, then the boot request (after reboot) will be handled by newly installed OS.
If as a part of the workflow, an OS is **not** installed, then the Worker after reboot will request PXE-boot from the Provisioner.

You can view the events and the state of a workflow during or after its execution with the tink CLI using the `tink workflow events` an the `tink workflow state` commands.

## Ephemeral Data

Ephemeral data is data that is shared between Workers as they execute workflows.
Ephemeral data is stored at `/workflow/<workflow_id>` in each tink-worker.

Initially the directory is empty; you populate with it by having the actions of a [template] write to it.
Then, the content in `/workflow/<workflow_id>` is pushed back to the database and from the database, pushed out to the other Workers.

As the workflow progresses, subsequent actions on a Worker can read any ephemeral data that's been created by previous actions on other Workers, as well as update that file with any changes.
Ephemeral data is only preserved through the life of a single workflow.
Each workflow that executes gets an empty file.

The data can take the form of a light JSON like below, or some binary files that other workers might require to complete their action.
There is a 10 MB limit for ephemeral data, because it gets pushed to and from the tink-server and tink-worker with every action, so it needs to be pretty light.

For instance, a Worker may write the following data:

```json
{
  "instance_id": "123e4567-e89b-12d3-a456-426655440000",
  "mac_addr": "F5:C9:E2:99:BD:9B",
  "operating_system": "ubuntu_18_04"
}
```

The other worker may retrieve and use this data and eventually add some more:

```json
{
  "instance_id": "123e4567-e89b-12d3-a456-426655440000",
  "ip_addresses": [
    {
      "address_family": 4,
      "address": "172.27.0.23",
      "cidr": 31,
      "private": true
    }
  ],
  "mac_addr": "F5:C9:E2:99:BD:9B",
  "operating_system": "ubuntu_18_04"
}
```

You can get the ephemeral data associated with a workflow with the `tink workflow data` tink CLI command.

[architecture]: ../images/workflow-diagram.png
[hardware data]: ../hardware-data.md
[template]: ../templates.md
