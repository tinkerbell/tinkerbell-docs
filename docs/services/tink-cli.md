---
title: Tink CLI
date: 2021-02-03
---

# Tink CLI

The `tink-cli` is an utility provided by the Tinkerbell community.
It is open source and you can find it as part of the [tinkerbell/tink] repository.

It is used as part of sandbox and delivered as a container or as binary.
Checkout the [Sandbox release page] to retrieve it in the format you need.

The CLI uses the Go gRPC [tink/client] to communicate with the [tink-server].

You can use the command line interface to create, delete or update workflows, hardware data and templates.
Or to fetch and filter those resources.

## Getting Started

All the traffic between Tinkerbell services is encrypted via TLS, so before running any `tink` commands you need to set the two environment variables that authenticate the CLI to the `tink-server`.
The `tink-server` entry point is 127.0.0.1 and is exposed on ports 42113 and 42114.

- `TINKERBELL_CERT_URL=http://127.0.0.1:42114/cert`
- `TINKERBELL_GRPC_AUTHORITY=127.0.0.1:42113`

NOTE: In a real environment, every person that has access to the host and ports can authenticate and use `tink-server`.

You can export them as environment variables or you can run them in-line as part of the `tink` command.

```
$ export TINKERBELL_GRPC_AUTHORITY=127.0.0.1:42113
$ export TINKERBELL_CERT_URL=http://127.0.0.1:42114/cert
```

Now you can run `tink` commands without `docker-exec`.

```
$ tink hardware list
>
+----+-------------+------------+----------+
| ID | MAC ADDRESS | IP ADDRESS | HOSTNAME |
+----+-------------+------------+----------+
+----+-------------+------------+----------+
```

You can also test by making some hardware data.

```
$ cat > hardware-data.json <<EOF
{
  "id": "ce2e62ed-826f-4485-a39f-a82bb74338e2",
  "metadata": {
    "facility": {
      "facility_code": "onprem"
    },
    "instance": {},
    "state": ""
  },
  "network": {
    "interfaces": [
      {
        "dhcp": {
          "arch": "x86_64",
          "ip": {
            "address": "192.168.1.5",
            "gateway": "192.168.1.1",
            "netmask": "255.255.255.248"
          },
          "mac": "08:00:27:00:00:01",
          "uefi": false
        },
        "netboot": {
          "allow_pxe": true,
          "allow_workflow": true
        }
      }
    ]
  }
}
EOF
tink hardware push < ./hardware-data.json
>
2020/08/31 10:20:20 Hardware data pushed successfully
```

## Build your own `tink-cli`

Prerequisites:

- A bit of familiarity with `go build`, and Go has to be installed.
- A Provisioner up and running Tinkerbell (works with the Vagrant setup, for example).

SSH into the Provisioner and navigate to the directory where you have cloned the `tink` repository.

```
ssh
cd tink
```

Now let's compile the binary with:

```
$ go build -o tink cmd/tink-cli/main.go
```

## Tink CLI Commands

The Tink CLI includes commands to create and manage workflows, templates, and hardware data.
Complete usage information is available from `tink --help` or `tink <command> --help`.

There is an ongoing effort to have a more consistent set of commands.
Watch out for breaking changes and deprecations.
In case of confusion, run `tink --help`.

[sandbox release page]: https://github.com/tinkerbell/sandbox/releases
[tink/client]: https://github.com/tinkerbell/tink/tree/main/client
[tinkerbell/tink]: https://github.com/tinkerbell/tink
[tink-server]: /services/tink-server
