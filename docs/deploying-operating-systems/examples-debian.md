---
title: Examples: Debian
date: 2021-03-12
---

# Deploying Debian

This is a guide which walks through the process of deploying Debian through a number of different mechanisms:

- Operating System Image
- Docker Image
- Bootstrap

## Operating System Image

Debian distribute their Operating System in a number of different formats, which are all available on the `cloud-images` web site [https://cdimage.debian.org/cdimage/cloud/OpenStack/current/](https://cdimage.debian.org/cdimage/cloud/OpenStack/current/). 

Below are two examples of images we can use:

```
debian-10-openstack-amd64.qcow2	   2021-03-04 10:56	  577M
debian-10-openstack-amd64.raw	      2021-03-04 10:53	  2.0G
```

The first image is a `qcow2` filesystem image and is a **full** disk image including partition tables, partitions filled with filesystems, files and importantly a boot loader at the begging of the disk image. 

The second image is a `raw` disk image an we can use it directly as it contains everything that we need to boot directly into Debian.

**Optionally** we can compress this raw image to save on both local disk space and network bandwidth when deploying the image.

`gzip ./debian-10-openstack-amd64.raw`

The raw image will now need moving to a locally accessible web server, we can place our image into the Tinkerbell sandbox webroot to simplify this usage. This will allow us to access our images at the IP address of the `tink-server`. 

`mv ./debian-10-openstack-amd64.raw.gz ./sandbox/deploy/state/webroot`

### Convert Image 

To convert our `qcow2` image to disk we will need to install the `qemu-img` cli tool.

`apt-get install -y qemu-utils`

We can now use this tool to convert our image into a `raw` filesystem:

`qemu-img convert  ./debian-10-openstack-amd64.qcow2 -O raw ./debian-10-openstack-amd64.raw`

**Optionally** we can compress this raw image to save on both local disk space and network bandwidth when deploying the image, the instructions are above.

### Writing our workflow

Our workflow will make use of the actions from the [artifact.io](https://artifact.io) hub:

- [image2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/image2disk) - to write the OS image to a block device
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned Operating System 

```
version: "0.1"
name: debian_Focal
global_timeout: 1800
tasks:
  - name: "os-installation"
	worker: "{{.device_1}}"
	volumes:
	  - /dev:/dev
	  - /dev/console:/dev/console
	  - /lib/firmware:/lib/firmware:ro
	actions:
	  - name: "stream debian image"
		image: quay.io/tinkerbell-actions/image2disk:v1.0.0
		timeout: 600
		environment:
		  DEST_DISK: /dev/sda
		  IMG_URL: "http://192.168.1.2/debian-10-openstack-amd64.raw.gz"
		  COMPRESSED: true
	  - name: "kexec debian"
		image: quay.io/tinkerbell-actions/kexec:v1.0.0
		timeout: 90
		pid: host
		environment:
		  BLOCK_DEVICE: /dev/sda1
			FS_TYPE: ext4
```

## Docker Image

We can easily make use of the **official** docker images to generate a root filesystem for use when deploying with Tinkerbell

### Download Debian image as root filesystem

```
TMPRFS=$(docker container create debian:latest)
docker export $TMPRFS > debian_rootfs.tar
docker rm $TMPRFS
```

**Optionally** we can compress this filesystem archive to save on both local disk space and network bandwidth when deploying the image.

`gzip ./debian_rootfs.tar`

The raw image will now need moving to a locally accessible web server, we can place our image into the Tinkerbell sandbox webroot to simplify this usage. This will allow us to access our images at the IP address of the `tink-server`. 

`mv ./debian_rootfs.tar.gz ./sandbox/deploy/state/webroot`

### Create workflow

Our workflow will make use of the actions from the artifact hub:

- [rootio](https://artifacthub.io/packages/tbaction/tinkerbell-community/rootio) - to partition our disk and make filesystems
- [archive2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/archive2disk) - to write the OS image to a block device
- [cexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/cexec) - to run commands inside (chroot) our newly provisioned Operating System
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned Operating System 

```
version: "0.1"
name: debian_bullseye_provisioning
global_timeout: 1800
tasks:
  - name: "os-installation"
	worker: "{{.device_1}}"
	volumes:
	  - /dev:/dev
	  - /dev/console:/dev/console
	  - /lib/firmware:/lib/firmware:ro
	actions:
	  actions:
	  - name: "disk-wipe-partition"
		image: quay.io/tinkerbell-actions/rootio:v1.0.0
		timeout: 90
		command: ["partition"]
		environment:
			MIRROR_HOST: 192.168.1.2
	  - name: "format"
		image: quay.io/tinkerbell-actions/rootio:v1.0.0
		timeout: 90
		command: ["format"]
		environment:
			MIRROR_HOST: 192.168.1.2
	  - name: "expand debian filesystem to root"
		image: quay.io/tinkerbell-actions/archive2disk:v1.0.0
		timeout: 90
		environment:
			ARCHIVE_URL: http://192.168.1.2/debian_rootfs.tar.gz
			ARCHIVE_TYPE: targz
			DEST_DISK: /dev/sda3
			FS_TYPE: ext4
			DEST_PATH: /
	  - name: "Install Grub Bootloader"
		image: quay.io/tinkerbell-actions/cexec:v1.0.0
		timeout: 90
		environment:
			  BLOCK_DEVICE: /dev/sda3
			FS_TYPE: ext4
			CHROOT: y
			CMD_LINE: "grub-install --root-directory=/boot /dev/sda"
	  - name: "kexec-debian"
		image: quay.io/tinkerbell-actions/kexec:v1.0.0
		timeout: 600
		environment:
		  BLOCK_DEVICE: /dev/sda3
		  FS_TYPE: ext4
```

## Bootstrap

The final method for installing Debian is to use the [grml-debootstrap](https://grml.org/grml-debootstrap/) installer. We will need to create an action that will invoke the installer and install to our local disk.

### Dockerfile

The below `dockerfile` will create a new image based upon Debian and install all of the components needed for `grml-debootstrap`... finally setting the `ENTRYPOINT` to execute the `grml-debootstrap` program to install to Debian to `/dev/sda3` and install the boot-loader to `/dev/sda`.

```
FROM debian:bullseye
RUN apt-get update; apt-get install -y grml-debootstrap
ENTRYPOINT ["grml-debootstrap", "--target", "/dev/sda3", "--grub", "/dev/sda"]
```

We can create an action image from our Dockerfile:

`docker build -t local-registry/debian:example .`

Once we have pushed our new action to the registry we can reference the action in a workflow as shown below.

```
actions:
- name: "expand ubuntu filesystem to root"
  image: local-registry/debian:bootstrap
  timeout: 90
```

### Workflow

Our workflow will make use of the actions from the artifact hubm and our custom actions:

- [rootio](https://artifacthub.io/packages/tbaction/tinkerbell-community/rootio) - to partition our disk and make filesystems
- Our custom action that will invoke the Bootstrap program
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned Operating System 

```
version: "0.1"
name: debian_bullseye_provisioning
global_timeout: 1800
tasks:
  - name: "os-installation"
	worker: "{{.device_1}}"
	volumes:
	  - /dev:/dev
	  - /dev/console:/dev/console
	  - /lib/firmware:/lib/firmware:ro
	actions:
	  actions:
	  - name: "disk-wipe-partition"
		image: quay.io/tinkerbell-actions/rootio:v1.0.0
		timeout: 90
		command: ["partition"]
		environment:
			MIRROR_HOST: 192.168.1.2
	  - name: "format"
		image: quay.io/tinkerbell-actions/rootio:v1.0.0
		timeout: 90
		command: ["format"]
		environment:
			MIRROR_HOST: 192.168.1.2
	  - name: "expand ubuntu filesystem to root"
		image: local-registry/debian:bootstrap
		timeout: 90
	  - name: "kexec-debian"
	    image: quay.io/tinkerbell-actions/kexec:v1.0.0
	    timeout: 600
	    environment:
	        BLOCK_DEVICE: /dev/sda3
	        FS_TYPE: ext4
```
