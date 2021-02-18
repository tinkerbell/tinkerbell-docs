---
title: Action Architecture
date: 2021-02-15
---

# Action Architecture

An action in Tinkerbell is a single unit of execution that takes place within a workflow, which itself is made from multiple actions in order to provision a piece of network booted infrastructure. An action ideally should contain a single task used as part of a longer chain of tasks, examples include:

- Wipe a Disk
- Partition disks
- Download files to the underlying disk
- Write keys to a TPM
- Create Users
- Write a cloud-init file
- [Kexec](https://wiki.archlinux.org/index.php/kexec#:~:text=Kexec%20is%20a%20system%20call,BIOS%20boot%20process%20to%20finish.) to a new Operating System

A Tinkerbell Action is contained within a container image and should be hosted on a registry. As the tink-worker executes a workflow it will pull action containers sequentially and execute them as containers. 

## Action Containers

As mentioned above an action runs within a container, which provides a number of inherent benefits:
- Contained code
- Re-usable modules
- Well established execution environment
- Use of existing infrastructure to host actions (container registry)

However, there are a number of usage concerns that must be considered when passing configuration in or using an action with the underlying hardware. 

### Action Container privileges

By default an action container is started as a [privileged](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) container, in numerous environments this is discouraged however with a requirement to the underlying hardware this is a requirement for a Tinkerbell action. This means that an action has direct access to hardware, such as block devices e.g. `/dev/sda` allowing us to wipe/partition/image the storage as an action. 

### Namespace

By default an action will be created in it's on Linux [Namespace](https://en.wikipedia.org/wiki/Linux_namespaces) meaning that whilst it can see underlying hardware, it is unaware of any other processes or existing network configuration (the Docker engine auto-magically manages external networking through the Docker network). This under the majority of use-cases is good for isolating what tasks an action is performing, however there are a number of use-cases where being able to communicate with the hosts existing processes is a requirement. The most obvious two (so far) are the capability to `reboot` or `kexec` into a new kernel, both of these actions typically involve a few steps:
1. Action calls the `/sbin/reboot` binary or `reboot()` syscall.
2. Kernel is aware of the reboot and sends a `signal` to process ID 1.
3. Process ID 1 (which should be `/init`) kills all processes and reboots the machine. 

When an action attempts to do these steps in a container in its own namespace, nothing will occur as PID 1 is usually the process in the action container. To allow the expected behaviour an action can use `pid: host` in its configuration, this will mean that the action processes will be amongst all of the processes on the host itself (including the "real" PID 1). With the action in the host process ID namespace both a `reboot` or `kexec` will be able to work as expected.

### Passing configuration to an action

Most actions can make use of reading the metadata during runtime, however there may be use-cases to keep a large standardised set of actions that can be written directly into a workflow.

An action should be created using an [`ENTRYPOINT`](https://docs.docker.com/engine/reference/builder/#entrypoint) meaning that we don't need to specify what needs to run within the action image. However if required there is the possibility to override this with the `command` section of the action configuration. 

e.g. Overwriting the command
```
command:
  - "/my_command.sh"
  - "-flag"
  - "argument"
```

The most common method to pass information into an action is through the usage of environment variables that are parsed by the action code as it is running. For example, if I had an action that needed to mount a disk the action would need to know the block device with the filesystem and the type of formatted filesystem on that device. We can pass that as shown below in the configuration of the action: 

```
environment:
  BLOCK_DEVICE: /dev/sda3
  FS_TYPE: ext4
```

With this understanding of the basic architecture of we can start to look at what would be required to [create your own action](./create-a-basic-action/).