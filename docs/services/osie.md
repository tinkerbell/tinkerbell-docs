---
title: OSIE
date: 2020-08-31
---

# The concept of operating system installation environment

An Operating System Installation Environment (OSIE) is the operating system shipped to the hardware you are provisioning. That operating system starts an application called tink-worker. At that point tink-worker will communicate with the Provisioner (tink-server) asking for a something to execute (a workflow).

Usually a workflow partitions the disk(s) and it installs an operating system that will be later used as boot device, leaving the hardware with the desired operating system.

When a hardware first starts there is nothing stored in its hard drive, and the bootloader will enter network mode. This mode runs PXE and it broadcasts a DHCP request asking for "something to do". [Boots](/services/boots) is one of the components shipped as part of the Tinkerbell Stack, it is a DHCP server. It handles the DHCP request and replies with a iPXE script to the hardware containing the operating system installation environment.

Right now we ship our one [OSIE](https://github.com/tinkerbell/osie) but you can build your own or modify the operating system in memory environment if you need kernel modules, drivers or applications that are not shipped from the Tinkerbell community.

# When You See OSIE

If you follow the [Vagrant Setup](/setup/local-vagrant) tutorial you encounter OSIE at the section "Start the Worker".

At that time the Worker has netbooted and Boots has pushed OSIE to the Worker, the workflow has started, and the Worker does not have an operating system yet.

![Screenshot from the Worker](/images/vagrant-setup-vbox-worker.png)

The `Welcome to Alpine Linux 4.7` message comes from OSIE.

# OSIE

[OSIE](https://github.com/tinkerbell/osie) is based on [AlpineLinux](https://alpinelinux.org/) a well known to be small (~130MB of storage) and easy to customize distribution. The boot process is minimal and it does not require much configuration. OSIE builds on that to provide an environment capable of running the right actions required to configure your Worker and install a persistent operating system.

OSIE gets compiled to a initial ramdisk and a kernel. The initial ramdisk contains Docker and it starts the [`tink-worker`](/services/tink) as a docker container. The `tink-worker` is the application that gets and manage workflows. Usually one of the first workflows it generates is the one that installs an operating system.

Currently, the OSIE of today is a bit "too fat"! We are in the process of moving a lot of the customization out of OSIE and into workflows.

# Write your own

As we mentioned you can run your own. And the reasons can be:

1. Your hardware have some proprietary kernel module not open source
2. You already have a distro can be netbooted and you want to use it
3. You want more visibility and you want to run a monitoring agent when the hardware does netbooting.
4. Many more...

The Equinix Metal DevRel team wrote [tinkie](https://github.com/gianarb/tinkie), another installation environment built using [LinuxKit](https://github.com/linuxkit/linuxkit). The way it is built and the code is open source. We decided to use LinuxKit because it is an open source builder for a Linux OS. It is part of the Linux Foundation and it is used by Docker Inc. to ship "Docker for Mac". It provides a layer of abstraction between a distro and how it gets built decreasing the amount of scripting involved and we hope it makes the process clear and easy to figure out.

Along the way of writing an operating system installation environment those are the requirements:

* It has to run **Tink Worker**. As we wrote earlier it is a Golang application maintained by the Tinkerbell community, you can find it as part of the [tink](https://github.com/tinkerbell/tink) repository, we ship and run it as Docker container. Its responsibility is to execute a workflow. Without it the OS will netboot, but won't do anything more.
* A [workflow](/workflows) is made of actions, and each action runs in its own **Docker** container. We decided to leverage containers because they are well known as execution and distribution layer. Developers can write their own action and the only thing they have to know is how to build and push a Docker container.
