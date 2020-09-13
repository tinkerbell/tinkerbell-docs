---
title: Hardware Operations
date: 2020-07-01
---

# Hardware Operations

```
  delete      Delete hardware data by ID.
  id          Get hardware data by ID.
  ip          Get hardware data by an associated IP Address.
  list        List the hardware data in the database.
  mac         Get hardware data by an associated MAC Address.
  push        Push new hardware data to the database.
  watch       Watch hardware data for changes.
```

`tink hardware --help` - Displays the available commands and usage for `tink hardware`.

## tink hardware delete

Deletes the specified hardware data.

```
tink hardware delete <ID> [--help] [--facility]
```

**Arguments**

- `ID` - The ID of the hardware data you want to delete from the database. Use multiple IDs to delete more than one hardware data at a time.

**Options**

- `-h`, `--help` - Displays usage for `delete`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink hardware delete 0eba0bf8-3772-4b4a-ab9f-6ebe93b90a25
>
2020/07/01 15:01:04 Hardware data with id 0eba0bf8-3772-4b4a-ab9f-6ebe93b90a25 deleted successfully
```

## tink hardware id

Returns hardware data for the specified ID or IDs as JSON objects.

```
tink hardware id <ID> [--help] [--facility]
```

**Arguments**

- `ID` - The ID of the hardware data you want to retrieve from the database. Use multiple IDs to retrieve more than one hardware data at a time.

**Options**

- `-h`, `--help` - Displays usage for `id`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink hardware id 0eba0bf8-3772-4b4a-ab9f-6ebe93b90a94
>
{"metadata":{"instance":{},"facility":{"facility_code":"onprem"}},"network":{"interfaces":[{"dhcp":{"mac":"08:00:27:00:00:01","arch":"x86_64","ip":{"address":"192.168.1.5","netmask":"255.255.255.248","gateway":"192.168.1.1"}},"netboot":{"allow_pxe":true,"allow_workflow":true}}]},"id":"0eba0bf8-3772-4b4a-ab9f-6ebe93b90a94"}
```

## tink hardware ip

Returns hardware data for the specified IP Address or IP Addresses as JSON objects.

```
tink hardware id <IP> [--details] [--help] [--facility]
```

**Arguments**

- `IP` - The IP address of the hardware data you want to retrieve from the database. Use multiple IP addresses to retrieve more than one hardware data at a time.

**Options**

- `-d`, `--details` - Displays the entire hardware data JSON for the specified IP address.
- `-h`, `--help` - Displays usage for `ip`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink hardware ip --details 192.168.1.5
>
{"metadata":{"instance":{},"facility":{"facility_code":"onprem"}},"network":{"interfaces":[{"dhcp":{"mac":"08:00:27:00:00:01","arch":"x86_64","ip":{"address":"192.168.1.5","netmask":"255.255.255.248","gateway":"192.168.1.1"}},"netboot":{"allow_pxe":true,"allow_workflow":true}}]},"id":"0eba0bf8-3772-4b4a-ab9f-6ebe93b90a94"}
```

## tink hardware list

Returns a list of all the hardware data that is currently stored in the database.

```
tink hardware list
```

**Options**

- `-h`, `--help` - Displays usage for `list`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink hardware list
>
+--------------------------------------+-------------------+-------------+-----------+
| ID                                   | MAC ADDRESS       | IP ADDRESS  | HOSTNAME  |
+--------------------------------------+-------------------+-------------+-----------+
| f9f56dff-098a-4c5f-a51c-19ad35de85d2 | 98:03:9b:89:d7:da | 192.168.1.4 | localhost |
| f9f56dff-098a-4c5f-a51c-19ad35de85d1 | 98:03:9b:89:d7:ba | 192.168.1.5 | worker_1  |
+--------------------------------------+-------------------+-------------+-----------+
```

## tink hardware mac

Returns hardware data for the specified MAC Address or MAC Addresses as JSON objects.

```
tink hardware mac <MAC> [--details] [--help] [--facility]
```

**Arguments**

- `MAC` - The MAC address of the hardware data you want to retrieve from the database. Use multiple MAC addresses to retrieve more than one hardware data at a time.

**Options**

- `-d`, `--details` - Displays the entire hardware data JSON for the specified MAC address.
- `-h`, `--help` - Displays usage for `mac`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink hardware mac --details 08:00:27:00:00:01
>
{"metadata":{"instance":{},"facility":{"facility_code":"onprem"}},"network":{"interfaces":[{"dhcp":{"mac":"08:00:27:00:00:01","arch":"x86_64","ip":{"address":"192.168.1.5","netmask":"255.255.255.248","gateway":"192.168.1.1"}},"netboot":{"allow_pxe":true,"allow_workflow":true}}]},"id":"0eba0bf8-3772-4b4a-ab9f-6ebe93b90a94"
```

## tink hardware push

Pushes the JSON-formatted hardware data from the specified file into the database.

```
tink hardware push --file <JSON_FILE> [--help] [--facility]
```

Or

```
cat <JSON_FILE> | tink hardware push
```

Or

```
tink hardware push < ./<JSON_FILE>
```

**Arguments**

- `JSON_FILE` - The file where the hardware data is defined in JSON format.

**Options**

- `--file`, `< ./<JSON_FILE>`, `cat <JSON_FILE>` - Specify the file containing the hardware data JSON. Alternatively, you can open and read the file instead.
- `-h`, `--help` - Displays usage for `push`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink hardware push --file data.json
>
2020/07/01 20:11:24 Hardware data pushed successfully
```

```
cat data.json | tink hardware push
>
2020/07/01 20:14:18 Hardware data pushed successfully
```

```
tink hardware push < ./data.json
>
2020/07/01 20:11:24 Hardware data pushed successfully
```

## tink hardware watch

Watch the specified hardware data for changes.

```
tink hardware watch <ID or IDs> [--help] [--facility]
```

**Arguments**

- `ID` - The ID of the hardware data you want to monitor for changes. Use multiple IDs to watch more than one hardware data.

**Options**

- `-h`, `--help` - Displays usage for `watch`.
- `-f`, `--facility` - string used to build grpc and http urls

**Examples**

```
tink hardware watch 0eba0bf8-3772-4b4a-ab9f-6ebe93b90a94
>

```
