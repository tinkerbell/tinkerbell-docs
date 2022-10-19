---
title: Hook
---

# Hook

Hook is the default light weight in-memory operating system used to provision a machine.
It is built using LinuxKit.
That operating system starts an application called [tink-worker] which communicates with [tink-server] to retrieve tasks for execution (tasks that are part of a workflow). 
The tasks performed by [tink-worker] typically result in a provisioned bare metal machine.

See the [Hook repository] for more information on its construction.

## Customizing Hook

Some users may need to customize Hook to include additional drivers for their hardware.
Follow the documentation in the [Hook repository] to build a [custom Kernel] and Hook.

<!-- TODO Do we want to bundle all documentation for customizations into the repository itself? -->

## Bring your own

You may wish to use your own operating system to provision machines.
To use your own OS with the Tinkerbell stack it must run [tink-worker], a Golang application maintained by the Tinkerbell community. 
[tink-worker] is shipped as a Docker container.
Its responsibility is to execute workflow tasks.

## Requirements

In order to successfully retrieve workflows from [tink-server], the following requirements must be met:

1. [boots] must be configured with either a `DOCKER_REGISTRY` env var, or the `BOOTS_EXTRA_KERNEL_ARGS` var, which would append a `tink_worker_image` boot parameter to `/proc/cmdline`, such as `tink_worker_image=my-awesome-registry.local/tink-worker:0.8.0`.

!!! note
    If only `DOCKER_REGISTRY` is set, then Hook will attempt to pull `${DOCKER_REGISTRY}/tink-worker:latest`.

2. [tink-server] must be accessible to the hardware via the `TINKERBELL_GRPC_AUTHORITY` env var passed to [boots]. 

!!! tip 
    If using an FQDN for `TINKERBELL_GRPC_AUTHORITY`, be sure to define DNS name servers for your hardware, per [hardware-data])

[alpine linux]: https://alpinelinux.org
[linuxkit]: https://github.com/linuxkit/linuxkit
[screenshot from the worker]: /images/vagrant-setup-vbox-worker.png
[tink]: https://github.com/tinkerbell/tink
[tink-server]: /services/tink-server
[tink-worker]: /services/tink-worker
[hardware-data]: /hardware-data
[boots]: /services/boots
[workflow]: /workflows/working-with-workflows
[hook repository]: https://github.com/tinkerbell/hook
[custom kernel]: https://github.com/tinkerbell/hook/tree/main/kernel
