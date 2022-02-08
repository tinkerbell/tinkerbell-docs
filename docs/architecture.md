---
title: Architecture
date: 2020-07-22
---

# Architecture

![Architecture]

## Provisioner

The provisioner machine is the main driver for executing a workflow.
The Provisioner houses and runs the [Tinkerbell stack], acts as the DHCP server, keeps track of hardware data, templates, and workflows.
You may divide these components into multiple servers that would then all function as your Provisioner.

### Provisioner Requirements

**OS**

The Tinkerbell stack has been tested on Ubuntu 16.04 and CentOS 7.

**Minimum Resources**

- CPU - 2vCPUs
- RAM - 4 GB
- Disk - 20 GB, this includes the OS

**Network**

L2 networking is required for the ability to run a DHCP server (in this case, Boots).

## Worker

A Worker machine is the target machine, identified by its hardware data, that calls back to the Provisioner and executes its specified workflows.
Any machine that has had its hardware data pushed into Tinkerbell can become a part of a workflow.
A Worker can be a part of multiple workflows.

### Worker Requirements

There are some very basic requirements that a Worker machine must meet in order to be able to boot and call back to the Provisioner.

- They must be able to boot from network using iPXE.
- 4 GB of RAM for OSIE boot and operation.

There are no Disk requirements for a Worker since OSIE runs an in-memory operating system.
Your disk requirements will be determined by the OS you are going to install and other use-case considerations.

[architecture]: /images/architecture-diagram.png
[tinkerbell stack]: /#whats-powering-tinkerbell
