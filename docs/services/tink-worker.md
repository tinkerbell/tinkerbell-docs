---
title: Tink Worker
---

# Tink Worker

Take a look at the code in the [tinkerbell/tink] GitHub repository.

Tink Worker is an agent that runs in the operating system installation environment. 
It is responsible for retrieving workflow actions from [Tink Server] and executing them. 
Actions are published as Docker containers with Tink Worker acting as their launcher. 
When an action finishes, Tink Worker reports the status to [Tink Server]

## How Tink Worker starts

Tink Worker's boot process does not follow any particular rule and it is left to the operating system installation environment.

In [Hook], Tinkerbell's default operating system installation environment, Tink Worker is launched by a multi-staged process. 
A small program called [hook-bootkit] is launched as a serivce, reads the Kernel command line for Tink Worker specific parameters, then launches Tink Worker as a Docker container. 
See the [LinuxKit configuration file][hook-bootkit-service] and [documentation][linuxkit] for how [hook-bootkit] is launched.

[tinkerbell/tink]: https://github.com/tinkerbell/tink/tree/main/cmd/tink-worker
[hook]: /hook
[tink server]: /services/tink-server
[hook-bootkit]: https://github.com/tinkerbell/hook/tree/main/hook-bootkit
[hook-bootkit-service]: https://github.com/tinkerbell/hook/blob/main/hook.yaml#L53
[linuxkit]: https://github.com/linuxkit/linuxkit