---
title: Boots
date: 2020-08-31
---

# Boots

Tinkerbell relies on network booting a server in order to prepare it to execute workflows.
Boots is Tinkerbell's DHCP server, handling IP addresses and requests.
It is also the TFTP server, serving iPXE and the initial installation image.

Boots is written in Go, and can built, run, and tested outside of the Tinkerbell stack.
Take a look at the code in the [tinkerbell/boots] GitHub repository.

## What Boots does

When a Worker comes on-line for the first time, it PXE boots and sends a DHCP request to the Provisioner.
Boots receives the request and assigns the Worker its IP Address as defined in the hardware data.

Next, Boots communicates over TFTP to download the iPXE script to the Worker.

The iPXE script tells the Worker to download and boot an in-memory operating system called [hook].
From there you are inside an OS and you can do what you like, the most common action is to partition your hard drive and installing the actual operating system.
Tinkerbell abstracts those actions with the concept of a workflow.

## Configuring an image registry requiring authentication

When using a registry requiring authentication Boots must be configured with the registry credentials so it can pass
them to Hook. The 3 required environment variables for authenticated registry access are:

```sh
DOCKER_REGISTRY: $TINKERBELL_HOST_IP
REGISTRY_USERNAME: $TINKERBELL_REGISTRY_USERNAME
REGISTRY_PASSWORD: $TINKERBELL_REGISTRY_PASSWORD
```

## Other Resources

One of the core concepts behind Tinkerbell is network booting.

Let's imagine you are in a datacenter with hundreds of servers; it is not reasonable to go over all of the one by one with a USB stick to install the operating system you need.
If you use Provisioner with an API, like Tinkerbell does, things get even more complicated as there isn't an operator running around with USB stick for every API request.

There are a lot of articles and use cases for netbooting, here a few that our contributors enjoyed or even wrote:

- [First journeys with netboot and ipxe installing Ubuntu]
- [The state of netbooting Raspberry Pis]
- [RedHat Enterprise Linux: PREPARING FOR A NETWORK INSTALLATION]

[first journeys with netboot and ipxe installing ubuntu]: https://gianarb.it/blog/first-journeys-with-netboot-ipxe
[hook]: ../hook.md
[redhat enterprise linux: preparing for a network installation]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/chap-installation-server-setup
[the state of netbooting raspberry pis]: https://blog.alexellis.io/the-state-of-netbooting-raspberry-pi/
[tinkerbell/boots]: https://github.com/tinkerbell/boots
