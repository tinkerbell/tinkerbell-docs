---
title: Workflow Operations
date: 2020-07-10
---

# Workflow Operations

```bash
  create      Create a workflow.
  data        Get the ephemeral data associated with a workflow.
  delete      Delete a workflow.
  events      Show all events for a workflow.
  get         Get a workflow as it exists in the database.
  list        List all the workflows in the database.
  state       get the current workflow context
```

`tink workflow --help` - Displays the available commands and usage for `tink workflow`.

## tink workflow create

Creates a workflow from a template ID and hardware data specified by MAC address or IP address. The workflow is stored in the database and the command returns a workflow ID.

```
tink workflow create --hardware <MAC_ADDRESS or IP_ADDRESS> --template <TEMPLATE_ID> [--help] [--facility]
```

**Arguments**

- `MAC_ADDRESS` or `IP_ADDRESS` - A JSON object containing the map of MAC or IP addresses of the hardware data used to identify the Worker (or workers) to their variables in the template. The key should match _worker_ field in the template and can only contain letters, numbers and underscores.
- `TEMPLATE_ID` - The ID of the workflow's template, returned by `tink template create`.

**Options**

- `-r`, `--hardware` - **Required** - Flag for the hardware data JSON mapping.
- `-t`, `--template` - **Required** - Flag for the template ID.
- `-h`, `--help` - Displays usage information for `create`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink workflow create -t aeedc9e2-6c1a-419f-976c-60f15803796f -r '{"device_1":"08:00:27:00:00:01"}'
>
Created Workflow:  3c5b71a7-0172-4d0d-bfff-6ca410b5697f
```

## tink workflow data

Returns the ephemeral data for a specified workflow.

```
tink workflow data <ID>
```

**Arguments**

- `ID` - The ID of the workflow that you want the ephemeral data from.

**Options**

- `-l`, `--latest version` - Returns the version number of the latest revision of the data.
- `-m`, `--metadata` - Returns the metadata only.
- `-v`, `--version` - Specify which version of the data to return.
- `-h`, `--help` - Displays usage information for `delete`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

## tink workflow delete

Deletes the specified workflow from the database. Doesn't return anything.

```
tink workflow delete <ID>
```

**Arguments**

- `ID` - The ID of the workflow that you want to delete. Use multiple IDs to delete more than one workflow at a time.

**Options**

- `-h`, `--help` - Displays usage information for `delete`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink workflow delete 3c5b71a7-0172-4d0d-bfff-6ca410b5697f
>
```

## tink workflow events

Returns the events and status of actions that are performed as part of workflow execution. If the workflow has not been executed, it returns an empty table.

```
tink workflow events <ID>
```

**Arguments**

- `ID` - The ID of the workflow you want to see the events for.

**Options**

- `-h`, `--help` - Displays usage information for `events`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink workflow events a8984b09-566d-47ba-b6c5-fbe482d8ad7f
>
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
| WORKER ID                            | TASK NAME   | ACTION NAME | EXECUTION TIME | MESSAGE                         |      ACTION STATUS |
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
| ce2e62ed-826f-4485-a39f-a82bb74338e2 | hello world | hello_world |              0 | Started execution               | ACTION_IN_PROGRESS |
| ce2e62ed-826f-4485-a39f-a82bb74338e2 | hello world | hello_world |              0 | Finished Execution Successfully |     ACTION_SUCCESS |
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
```

## tink workflow get

Returns the workflow as it exists in the database. Useful for checking that the Worker's MAC or IP Address was correctly added at workflow creation.

```
tink workflow get <ID>
```

**Arguments**

- `ID` - The ID of the workflow you want to get.

**Options**

- `-h`, `--help` - Displays usage information for `get`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink workflow get fe9a7798-19da-4968-be99-3f111aa789c0
>
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

## tink workflow list

Lists all the workflows currently stored in the database.

```
tink workflow list <ID> [--help] [--facility]
```

**Options**

- `-h`, `--help` - Displays usage information for `get`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink workflow list
>
+--------------------------------------+--------------------------------------+-----------------------------------+-------------------------------+-------------------------------+
| WORKFLOW ID                          | TEMPLATE ID                          | HARDWARE DEVICE                   | CREATED AT                    | UPDATED AT                    |
+--------------------------------------+--------------------------------------+-----------------------------------+-------------------------------+-------------------------------+
| 7d81e2e3-5309-47d3-b4b0-8ba7bc02078b | c918a54a-5267-4efe-b884-849bcae9af65 | {"device_1": "08:00:27:00:00:01"} | 2020-07-08 15:17:02 +0000 UTC | 2020-07-08 15:17:02 +0000 UTC |
+--------------------------------------+--------------------------------------+-----------------------------------+-------------------------------+-------------------------------+
```

## tink workflow state

Returns a summary of workflow status or progress. If run during workflow execution, it will return which task and action the workflow is currently working on.

```
tink workflow state <ID> [--help] [--facility]
```

**Arguments**

- `ID` - The ID of the workflow you want to get state information for.

**Options**

- `-h`, `--help` - Displays usage information for `state`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink workflow state 7d81e2e3-5309-47d3-b4b0-8ba7bc02078b
>
+----------------------+--------------------------------------+
| FIELD NAME           | VALUES                               |
+----------------------+--------------------------------------+
| Workflow ID          | 7d81e2e3-5309-47d3-b4b0-8ba7bc02078b |
| Workflow Progress    | 0%                                   |
| Current Task         |                                      |
| Current Action       |                                      |
| Current Worker       |                                      |
| Current Action State | ACTION_PENDING                       |
+----------------------+--------------------------------------+
```
