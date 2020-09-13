---
title: Template Operations
date: 2020-07-02
---

# Template Operations

```
  create      Create a template in the database.
  delete      Delete a template from the database.
  get         Get a template by ID.
  list        List all templates in the database.
  update      Update an existing template.
```

`tink template --help` - Displays the available commands and usage for `tink template`.

## tink template create

Creates the template from the YAML file, and pushes it to the database. It returns a UUID for the newly created template.

```
tink template create --name <NAME> --path <PATH> [--help] [--facility]
```

**Arguments**

- `NAME` - The name for the new template.
- `PATH` - The path to the template file.

**Options**

- `-h`, `--help` - Displays usage information for `create`.
- `-n`, `--name` - Specify a name for the template. Must be unique and alphanumeric.
- `-p`, `--path`, `< ./<PATH>` - Path to the template file. Alternatively, you can open and read the file instead.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
template create --name hello-world < ./hello-world.yml
>
Created Template:  b8dbcf07-39dd-4018-903e-1748ecbd1986
```

## tink template delete

Deletes a template from the database. Doesn't return anything.

```
tink template delete <ID> [--help] [--facility]
```

**Arguments**

- `ID` - The ID of the template that you want to delete. Use multiple IDs to delete more than one template at a time.

**Options**

- `-h`, `--help` - Displays usage information for `delete`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink template delete b8dbcf07-39dd-4018-903e-1748ecbd1986
>

```

## tink template get

Returns the specified template or templates in YAML format.

```
tink template get <ID> [--help] [--facility]
```

**Arguments**

- `ID` - The ID of the template you want to retrieve from the database. Use multiple IDs to retrieve more than one template at a time.

**Options**

- `-h`, `--help` - Displays usage information for `get`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink template get 160d2cbf-d1ed-496d-9ade-7347b2853cbf
>
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

## tink template list

Lists templates stored in the database in a formatted table.

```
tink template list
```

**Options**

- `-h`, `--help` - Displays usage information for `list`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink template list
>
+--------------------------------------+-------------------+-------------------------------+-------------------------------+
| TEMPLATE ID                          | TEMPLATE NAME     | CREATED AT                    | UPDATED AT                    |
+--------------------------------------+-------------------+-------------------------------+-------------------------------+
| 9c7d2a12-8dcb-406c-82a8-f41d2efd8ebf | hello-world-again | 2020-07-06 14:39:19 +0000 UTC | 2020-07-06 14:39:19 +0000 UTC |
| 160d2cbf-d1ed-496d-9ade-7347b2853cbf | hello-world       | 2020-07-06 14:36:15 +0000 UTC | 2020-07-06 14:36:15 +0000 UTC |
+--------------------------------------+-------------------+-------------------------------+-------------------------------+
```

## tink template update

Updates an existing template with either a new name, or by specifying a new or updated YAML file.

```
tink template update <ID> [--name <NAME>] [--path <PATH>] [--help] [--facility]
```

**Arguments**

- `ID` - The ID of the template you want to update.

**Options**

- `-h`, `--help` - Displays usage information for `update`.
- `-n`, `--name` - Specify a new name for the template. Must be unique and alphanumeric.
- `-p`, `--path`, `< ./<PATH>` - Path to the updated template file. Alternatively, you can open and read the file instead.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

Update the name of an existing template.

```
tink template update 160d2cbf-d1ed-496d-9ade-7347b2853cbf --name renamed-hello-world
>
Updated Template:  160d2cbf-d1ed-496d-9ade-7347b2853cbf
```

Update an existing template and keep the same name.

```
tink template update 9c7d2a12-8dcb-406c-82a8-f41d2efd8ebf < ./tmp/new-sample-template.tmpl
>
Updated Template:  160d2cbf-d1ed-496d-9ade-7347b2853cbf
```
