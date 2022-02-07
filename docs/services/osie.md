---
title: OSIE
date: 2021-02-03
---

# OSIE

## The Concept of an Operating System Installation Environment

An Operating System Installation Environment (OSIE) is the operating system shipped to the hardware you are provisioning.
That operating system starts an application called `tink-worker`.
At that point `tink-worker` will communicate with the Provisioner (running `tink-server`) asking for a something to execute (a workflow).

Usually a workflow partitions the disk(s) and it installs an operating system that will be later used as boot device, leaving the hardware with the desired operating system.

When a hardware first starts, there is nothing stored in its hard drive and the bootloader will enter network mode.
This mode runs PXE and it broadcasts a DHCP request asking for "something to do".
[Boots](/services/boots) is one of the components shipped as part of the Tinkerbell Stack, it is a DHCP server.
It handles the DHCP request and replies with a iPXE script to the hardware containing the operating system installation environment.

Right now we ship our one [OSIE](https://github.com/tinkerbell/osie) but you can build your own or modify the operating system in memory environment if you need kernel modules, drivers or applications that are not shipped from the Tinkerbell community.

## When You See OSIE

If you follow the [Vagrant Setup](/setup/local-vagrant) tutorial you encounter OSIE at the section "Start the Worker".

At that time the Worker has netbooted and Boots has pushed OSIE to the Worker, the workflow has started, and the Worker does not have an operating system yet.

![Screenshot from the Worker](/images/vagrant-setup-vbox-worker.png)

The `Welcome to Alpine Linux 4.7` message comes from OSIE.

## The Current OSIE

Tinkerbell's current [OSIE](https://github.com/tinkerbell/osie) is based on [AlpineLinux](https://alpinelinux.org/), a well known to be small (~130MB of storage) and easy to customize distribution.
The boot process is minimal and it does not require much configuration.
OSIE builds on that to provide an environment capable of running the right actions required to configure your Worker and install a persistent operating system.

OSIE gets compiled to a initial ramdisk and a kernel.
The initial ramdisk contains Docker and it starts the [`tink-worker`](/services/tink) as a docker container.
The `tink-worker` is the application that gets and manage workflows.
Usually one of the first workflows it generates is the one that installs an operating system.

Currently, the OSIE of today is a bit "too fat"!
We are in the process of moving a lot of the customization out of OSIE and into workflows.

## Hook, the OSIE Replacement

The Tinkerbell architecture allows for flexibility in terms of the operating system installation environment you can use.
It provides OSIE for simplicity, it is possible to develop alternatives.

One possible alternative is Hook, an installation environment built using [LinuxKit](https://github.com/linuxkit/linuxkit).
The `tinkerbell/hook` project aims to provide an "in-place" swappable set of files (`kernel`/`initramfs`) that can be used to replace the [OSIE](https://github.com/tinkerbell/osie) environment, which originally came from Equinix Metal.
The key aims of this new project are:

- Immutable output
- Batteries included (but swappable if needed)
- Ease of build (Subsequent builds of hook are ~47 seconds)
- Lean and simple design
- Clean base to build upon

More information and on-going development is in the [`tinkerbell/hook`](https://github.com/tinkerbell/hook) GitHub repository.

## Write Your Own

As we mentioned you can run your own OSIE.
And the reasons can be:

1. Your hardware have some proprietary kernel module not open source.
2. You already have a distro can be netbooted and you want to use it.
3. You want more visibility and you want to run a monitoring agent when the hardware does netbooting.
4. Many more...

If you are writing your own operating system installation environment, there are a few requirements:

- It has to run **Tink Worker**.
  [tink-worker](/servces/tink) is a Golang application maintained by the Tinkerbell community, you can find it as part of the [tink](https://github.com/tinkerbell/tink) repository, we ship and run it as Docker container.
  Its responsibility is to execute a workflow.
  Without it the OS will netboot, but won't do anything more.
- A [workflow](../../workflows/working-with-workflows) is made of actions, and each action runs in its own **Docker** container.
  We decided to leverage containers because they are well known as an execution and distribution layer.
  Developers can write their own actions, and the only thing they have to know is how to build and push a Docker container.
