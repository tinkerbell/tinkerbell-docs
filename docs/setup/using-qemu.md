---
title: Bare Metal or Equinix Metal with QEMU
date: 2021-01-27
---

# Bare Metal or Equinix Metal with QEMU

## Prerequisites

This is a rough shopping list of skills/accounts that will be a benefit for this guide.

- Access to bare metal infrastructure either a local server or a bare metal provider
- `GO` experience (basic)
- `iptables` usage (basic)
- `qemu` usage (basic)

## Our Tinkerbell server considerations

Some "finger in the air" mathematics are generally required when selecting an appropriately sized physical host.
But if we take a quick look at the expected requirements:

```
CONTAINER ID        NAME                   CPU %               MEM USAGE / LIMIT    MEM %               NET I/O             BLOCK I/O           PIDS
582ce8ba4cdf        deploy_tink-cli_1      0.00%               832KiB / 7.79GiB     0.01%               0B / 0B             13.1MB / 0B         1
4aeb11684865        deploy_tink-server_1   0.00%               7.113MiB / 7.79GiB   0.09%               75.7MB / 76.6MB     4.94MB / 0B         11
24c7c5961a2b        deploy_boots_1         0.00%               8.652MiB / 7.79GiB   0.11%               0B / 0B             5.66MB / 0B         7
37d2e840bd54        deploy_registry_1      0.02%               8.344MiB / 7.79GiB   0.10%               0B / 0B             1.32MB / 0B         11
a70a54baff08        deploy_hegel_1         0.00%               2.984MiB / 7.79GiB   0.04%               0B / 0B             246kB / 0B          5
33d953c9b057        deploy_db_1            13.66%              6.363MiB / 7.79GiB   0.08%               24.7MB / 22.2MB     1.5MB / 1.34GB      8
2fa8a6064036        deploy_nginx_1         0.00%               2.867MiB / 7.79GiB   0.04%               341kB / 0B          0B / 0B             3
```

We can see that the components for the Tinkerbell stack are particularly light, with this in mind we can be very confident that we can have all of our userland components (tinkerbell/docker/bash etc..) within 1 GB of ram and leave all remaining memory for the virtual machines.

That brings us onto the next part, which is how big should the virtual machines be?

### Operating System Installation Environment (OSIE)

Every machine that is booted by Tinkerbell will be passed the in-memory Operating System called `OSIE` which is an alpine based Linux OS that ultimately will run the workflows.
As this is all in-memory, we will need to account for a few things before we install our Operating System through a workflow.

- OSIE kernel
- OSIE RAM Disk (Includes Alpine userland and the docker engine) - The **OSIE Ram Disk**, whilst it looks like a normal filesystem, is actually held in the memory of the host itself so it will immediately withhold that memory from other usage.
- Action images (at rest) - The **Action image** will be pulled locally from a repository and again written to disk, **however** the disk that these images are written to is a RAM disk, so these images will withhold available memory.
- Action containers (running) - These images, when run (**Action containers**), will have binaries in them that will require available memory in order to run.

The majority of this memory usage is for the in-memory filesystem in order to host the userland tools and the images listed in the workflow.
From testing we've normally seen that **> 2 GB** is required, however if your workflow consists of large action images then this will need adjusting accordingly.

With all this in consideration, we can use Equinix Metal machines T-Shirt sizes to determine the size of machine required.
Given the minimal overhead for Tinkerbell and userland then a `t1.small.x86` with 1 CPU and 8 GB of RAM is sufficient.
However if you're looking at deploying multiple machines with Tinkerbell then ideally a machine with 32 GB of ram will comfortably allow a comfortable amount of headroom.

### Recommended machine size and OS

When selecting a bare metal host to run Tinkerbell and provision machines onto QEMU we recommend one or more CPUs and 8GB of ram is going to be required in order to successfully provision machine instances with Tinkerbell.

#### In Equinix Metal

Check the inventory of your desired facility, but the recommended instances are below:

- `c1.small.x86`
- `c3.small.x86`
- `x1.small.x86`

For speed of deployment and modernity of the Operating System, either Ubuntu 18.04 or Ubuntu 20.04 are recommended.

## Deploying Tinkerbell

This examples uses a `c3.small.x86` in the Amsterdam facility `ams6` with `ubuntu 20.04`.
Once our machine is up and running, we'll need to install our required packages for running Tinkerbell and our virtual machines.

1.  Update the packages.

    ```
    apt-get update -y
    ```

2.  Install the required dependencies.

        ```
        apt-get install -y apt-transport-https \
         ca-certificates \
         curl \
         gnupg-agent \
         software-properties-common \
         qemu-kvm \
         libguestfs-tools \
         libosinfo-bin \
         git
         jq
        ```

    This installation method also requires Docker and [`docker-compose`](https://docs.docker.com/compose/install/#install-compose-on-linux-systems):

```
    apt-get install -y docker.io ; \
    curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose ; \
    chmod +x /usr/local/bin/docker-compose
```

3. Grab shack (QEMU wrapper).

   ```
   wget https://github.com/plunder-app/shack/releases/download/v0.0.0/shack-0.0.0.tar.gz; \
   tar -xvzf shack-0.0.0.tar.gz; \
   mv shack /usr/local/bin
   ```

4. Create our internal Tinkerbell network (optional).

   ```
   sudo ip link add tinkerbell type bridge
   ```

5. Create shack configuration.

   ```
   shack example > shack.yaml
   ```

6. Edit and apply the configuration.

   Change the bridgeName: from `plunder` to `tinkerbell`, then run `shack network create`.
   This will create a new interface on our Tinkerbell bridge

   Run `shack network create`

7. Test virtual machine creation.

   ```
   shack vm start --id f0cb3c -v
   <...>
   shack VM configuration
   Network Device:	plndrVM-f0cb3c
   VM MAC Address:	c0:ff:ee:f0:cb:3c
   VM UUID:	f0cb3c
   VNC Port:	6671
   ```

   We can also examine that this has worked, by examining `ip addr`:

   ```
   11: tinkerbell: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
       link/ether 2a:27:61:44:d2:07 brd ff:ff:ff:ff:ff:ff
       inet 192.168.1.1/24 brd 192.168.1.255 scope global plunder
          valid_lft forever preferred_lft forever
       inet6 fe80::bcc7:caff:fe63:8016/64 scope link
          valid_lft forever preferred_lft forever
   12: plndrVM-f0cb3c: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master plunder state UP group default qlen 1000
       link/ether 2a:27:61:44:d2:07 brd ff:ff:ff:ff:ff:ff
       inet6 fe80::2827:61ff:fe44:d207/64 scope link
          valid_lft forever preferred_lft forever
   ```

   Connect to the VNC port with a client (the random port generated in this example is `6671`).
   It will be exposed on the public address of our Equinix Metal host.

   Kill the VM:

   ```
   shack vm stop --id f0cb3c -d
   ```

8. Install sandbox dependencies.

   The steps for deploying the Tinkerbell sandbox can be found here [https://docs.tinkerbell.org/setup/on-bare-metal-with-docker/#getting-tinkerbell](https://docs.tinkerbell.org/setup/on-bare-metal-with-docker/#getting-tinkerbell)

   As we're using QEMU and the shack program we will need to set things up slightly different, using the steps below.

9. Configure the sandbox.

   ```
   ./generate-envrc.sh tinkerbell > .env
   ./setup.sh
   ```

10. Start Tinkerbell.

    ```
    cd deploy
    source ../.env; docker-compose up -d
    ```

    At this point we now have a server with available resource, we can create virtual machines and Tinkerbell is listening on the correct internal network!

    Resources inside the Tinkrebell will be reachable as per the below details

    ```
    - webroot: TINKERBELL_IP:8080
    - webroot/misc/osie/current: TINKERBELL_IP:80
    ```

## Create a workflow (Debian example)

1. Clone the Debian repository.

   ```
   cd $HOME
   git clone https://github.com/fransvanberckel/debian-workflow
   cd debian-workflow/debian
   ```

2. Build the Debian content.

   ```
   ./verify_json_tweaks.sh
   # The JSON syntax is valid
   ./build_and_push_images.sh
   ```

3. Edit the configuration.

   Modify the `create_tink_workflow.sh` so that the mac address is `c0:ff:ee:f0:cb:3c`, this is the mac address we will be using as part of our demonstration.

   For using VNC, modify the `facility.facility_code` from `"onprem"` to `"onprem console=ttys0 vha=normal"`.
   This will ensure all output is printed to the VNC window that we connect to.

4. Create the workflow.

   Here we will be asked for some password credentials for our new machine:

   ```
   ./create_tink_workflow.sh
   ```

## Start our virtual host to install on!

```
shack vm start --id f0cb3c -v
<...>
shack VM configuration
Network Device:	plndrVM-f0cb3c
VM MAC Address:	c0:ff:ee:f0:cb:3c
VM UUID:	f0cb3c
VNC Port:	6671
```

We can now watch the install on the VNC port `6671`

## Troubleshooting

- **could not configure /dev/net/tun (plndrVM-f0cb3c): Device or resource busy**

  This means that an old QEMU session left an old adapter, we can remove it with the command, `ip link delete plndrVM-f0cb3c`.

- **Is another process using the image [f0cb3c.qcow2]?**

  We've left an old disk image laying around, we can remove this with `rm`.
