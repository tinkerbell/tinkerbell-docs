---
title: Tink Worker
---

# Tink Worker

[tink-worker] is a component provided by the Tinkerbell community and can be found in the [tinkerbell/tink] repository.

You can think of [tink-worker] as the "smart" part of an operating system installation environment.
It is an agent that runs in the operating system and its responsibility is to interact with the [tink-server], identifying and executing tasks targeting the hardware it runs on.

The [tink-worker] implementation we ship uses Docker as container runtime engine.
Every action gets executed as a container.

## How [tink-worker] starts

[tink-worker]'s boot process does not follow any particular rule and it is left to the operating system installation environment.

In [Hook], [tink-worker] is launched by a multi-staged process. 
In short, a small program called [hook-bootkit] is launched as a serivce, reads the Kernel command line for [tink-worker] specific parameters, then launches [tink-worker] as a Docker container. See the [LinuxKit configuration file][hook-bootkit-service] and [documentation][linuxkit] for how [hook-bootkit] is launched.

[hook]: /services/hook
[tinkerbell/tink]: https://github.com/tinkerbell/tink/tree/main/cmd/tink-worker
[tink-server]: /services/tink-server
[tink-worker]: /services/tink-worker
[hook-bootkit]: https://github.com/tinkerbell/hook/tree/main/hook-bootkit
[hook-bootkit-service]: https://github.com/tinkerbell/hook/blob/main/hook.yaml#L53
[linuxkit]: https://github.com/linuxkit/linuxkit