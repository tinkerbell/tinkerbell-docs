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

<!-- TODO Elaborate on Tink worker configuration requirements for it to retrieve the correct workflows. -->

[alpine linux]: https://alpinelinux.org
[linuxkit]: https://github.com/linuxkit/linuxkit
[screenshot from the worker]: /images/vagrant-setup-vbox-worker.png
[tink]: https://github.com/tinkerbell/tink
[tink-server]: /services/tink-server
[tink-worker]: /services/tink-worker
[workflow]: /workflows/working-with-workflows
[hook repository]: https://github.com/tinkerbell/hook
[custom kernel]: https://github.com/tinkerbell/hook/tree/main/kernel
