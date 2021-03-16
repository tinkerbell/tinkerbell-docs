---
title: Examples: Ubuntu
date: 2021-03-12
---

# Deploying Ubuntu

This is a guide which walks through the process of deploying Ubuntu through a number of different mechanisms:

- Operating System Image
- Docker Image

## Operating System Image

Ubuntu distribute their Operating System in a number of different formats, which are all available on the `cloud-images` web site [https://cloud-images.ubuntu.com/daily/server/focal/current/](https://cloud-images.ubuntu.com/daily/server/focal/current/). 

Below are two examples of images we can use:

```
focal-server-cloudimg-amd64.img     2021-03-11 22:27  528M  Ubuntu Server 20.04 LTS (Focal Fossa) daily builds
focal-server-cloudimg-amd64.tar.gz  2021-03-11 22:30  485M  File system image and Kernel packed
```

The first image (with the extension `.img`) is actually a `qcow2` filesystem image and is a **full** disk image including partition tables, partitions filled with filesystems, files and importantly a boot loader at the begging of the disk image. 

The second image is a file system image, in particular it is typically an `ext4` filesystem that contains all of the files in a partition for Ubuntu to run. However in order for us to use this image we would need to:

- Partition the disk
- Write this data to the partition
- Install a boot loader

With all of this in mind, it becomes much simpler to convert the `qcow2` image and simply write it to disk.
   
### Convert Image 

To convert our image to disk we will need to install the `qemu-img` cli tool.

`apt-get install -y qemu-utils`

We can now use this tool to convert our image into a `raw` filesystem:

`qemu-img convert  ./focal-server-cloudimg-amd64.img -O raw ./focal-server-cloudimg-amd64.raw`

**Optionally** we can compress this raw image to save on both local disk space and network bandwidth when deploying the image.

`gzip ./focal-server-cloudimg-amd64.raw`

The raw image will now need moving to a locally accessible web server, we can place our image into the Tinkerbell sandbox webroot to simplify this usage. This will allow us to access our images at the IP address of the `tink-server`. 

`mv ./focal-server-cloudimg-amd64.raw ./sandbox/deploy/state/webroot`

### Writing our workflow

Our workflow will make use of the actions from the [artifact.io](https://artifact.io) hub:

- [image2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/image2disk) - to write the OS image to a block device
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned Operating System 

```
version: "0.1"
name: Ubuntu_Focal
global_timeout: 1800
tasks:
  - name: "os-installation"
	worker: "{{.device_1}}"
	volumes:
	  - /dev:/dev
	  - /dev/console:/dev/console
	  - /lib/firmware:/lib/firmware:ro
	actions:
      - name: "stream ubuntu image"
        image: quay.io/tinkerbell-actions/image2disk:v1.0.0
		timeout: 600
		environment:
		  DEST_DISK: /dev/sda
		  IMG_URL: "http://192.168.1.2/focal-server-cloudimg-amd64.raw.gz"
		  COMPRESSED: true
      - name: "kexec ubuntu"
	    image: quay.io/tinkerbell-actions/kexec:v1.0.0
	    timeout: 90
	    pid: host
	    environment:
    	  BLOCK_DEVICE: /dev/sda1
	  	  FS_TYPE: ext4
```

## Docker Image

We can easily make use of the **official** docker images to generate a root filesystem for use when deploying with Tinkerbell

### Download Ubuntu image as root filesystem

```
TMPRFS=$(docker container create ubuntu:latest)
docker export $TMPRFS > ubuntu_rootfs.tar
docker rm $TMPRFS
```

**Optionally** we can compress this filesystem archive to save on both local disk space and network bandwidth when deploying the image.

`gzip ./ubuntu_rootfs.tar`

The raw image will now need moving to a locally accessible web server, we can place our image into the Tinkerbell sandbox webroot to simplify this usage. This will allow us to access our images at the IP address of the `tink-server`. 

`mv ./ubuntu_rootfs.tar.gz ./sandbox/deploy/state/webroot`

### Create workflow

Our workflow will make use of the actions from the artifact hub:

- [rootio](https://artifacthub.io/packages/tbaction/tinkerbell-community/rootio) - to partition our disk and make filesystems
- [archive2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/archive2disk) - to write the OS image to a block device
- [cexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/cexec) - to run commands inside (chroot) our newly provisioned Operating System
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned Operating System 

```
version: "0.1"
name: ubuntu_provisioning
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
	    image: quay.io/tinkerbell-actions/archive2disk:v1.0.0
	    timeout: 90
	    environment:
		    ARCHIVE_URL: http://192.168.1.2/ubuntu_rootfs.tar.gz
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
	  - name: "kexec-ubuntu"
		image: quay.io/tinkerbell-actions/kexec:v1.0.0
		timeout: 600
		environment:
		  BLOCK_DEVICE: /dev/sda3
		  FS_TYPE: ext4
```