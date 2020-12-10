---
title: OSIE
date: 2020-08-31
---

# OSIE

When a Worker first starts in a Tinkerbell environment, it network boots and contacts the Provisioner where [Boots](/services/boots) handles its DHCP settings and provides iPXE support. As part of this process Tinkerbell sets up the Worker with an in-memory operating system called OSIE and is based on [Alpine](https://alpinelinux.org).

OSIE is downloaded to the Worker via iPXE. Usually, this will happen when a Worker network boots and an operating system is not installed, otherwise the bootloader will boot from the disk which contains your operating system.

OSIE can built, run, and tested outside of the Tinkerbell stack. Take a look at the code in its GitHub repository: [tinkerbell/osie](https://github.com/tinkerbell/osie).

## Alpine and OSIE

Alpine is known to be small (~130MB of storage) and easy to customize. The boot process is minimal and it does not require much configuration. OSIE builds on that to provide an environment capable of running the right actions required to configure your Worker and install a persistent operating system.

OSIE gets compiled to a initial ramdisk and a kernel. The initial ramdisk contains Docker and it starts the [`tink-worker`](/services/tink) as a docker container. The `tink-worker` is the application that gets and manage workflows. Usually one of the first workflows it generates is the one that installs an operating system.

Currently, the OSIE of today is a bit "too fat"! We are in the process of moving a lot of the customization out of OSIE and into workflows.

## When You See OSIE

If you follow the [Vagrant Setup](/setup/local-vagrant) tutorial you encounter OSIE at the section "Start the Worker".

At that time the Worker has netbooted and Boots has pushed OSIE to the Worker, the workflow has started, and the Worker does not have an operating system yet.

![Screenshot from the Worker](/images/vagrant-setup-vbox-worker.png)

The `Welcome to Alpine Linux 4.7` message comes from OSIE.
