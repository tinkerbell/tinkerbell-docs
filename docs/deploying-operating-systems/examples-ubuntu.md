---
title: Example - Ubuntu
date: 2021-03-12
---

# Deploying Ubuntu

This guide walks through the process of deploying Ubuntu from either an operating system image or a Docker image.

## Using an Operating System Image

Ubuntu is distributed in a number of different formats, which are all available on the `cloud-images` web site: [https://cloud-images.ubuntu.com/daily/server/focal/current/](https://cloud-images.ubuntu.com/daily/server/focal/current/). 

This example uses the image with the `.img` extension.

```
focal-server-cloudimg-amd64.img     2021-03-11 22:27  528M  Ubuntu Server 20.04 LTS (Focal Fossa) daily builds
```

This image is actually a `qcow2` filesystem image and is a **full** disk image including partition tables, partitions filled with filesystems and the files, and importantly, a boot loader at the beginning of the disk image.
   
### Converting Image 

In order to use this image, it needs to be converted into a `raw` filesystem. In order to do the conversion, install the `qemu-img` CLI tool.

```
apt-get install -y qemu-utils
```

Then, use the tool to convert the image into a `raw` filesystem.

```
qemu-img convert  ./focal-server-cloudimg-amd64.img -O raw ./focal-server-cloudimg-amd64.raw
```

**Optional** - You can compress this raw image to save on both local disk space and network bandwidth when deploying the image.

```
gzip ./focal-server-cloudimg-amd64.raw
```

Move the raw image to a locally accessible web server. To simplify, you can place the image in the Tinkerbell sandbox webroot, which allows access to the image at the IP address of the `tink-server`.

```
mv ./focal-server-cloudimg-amd64.raw ./sandbox/deploy/state/webroot`
```

### Creating the Template

The template uses [actions](https://github.com/artifacthub/hub/blob/master/docs/metadata/artifacthub-pkg.yml) from the [artifacthub.io](https://artifacthub.io).

- [image2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/image2disk) - to write the OS image to a block device.
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned operating system.

> Important: Don't forget to pull, tag, and push `quay.io/tinkerbell-actions/image2disk:v1.0.0` prior to using it.

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
      - name: "stream-ubuntu-image"
        image: quay.io/tinkerbell-actions/image2disk:v1.0.0
		timeout: 600
		environment:
		  DEST_DISK: /dev/sda
		  IMG_URL: "http://192.168.1.1:8080/focal-server-cloudimg-amd64.raw.gz"
		  COMPRESSED: true
      - name: "kexec-ubuntu"
	    image: quay.io/tinkerbell-actions/kexec:v1.0.0
	    timeout: 90
	    pid: host
	    environment:
    	  BLOCK_DEVICE: /dev/sda1
	  	  FS_TYPE: ext4
```

### File System Images

Note that it is also possible to install Ubuntu from the compressed filesystem image. 

```
focal-server-cloudimg-amd64.tar.gz  2021-03-11 22:30  485M  File system image and Kernel packed
```

This filesystem image is typically an `ext4` filesystem that contains all of the files in a partition for Ubuntu to run. However, in order for us to use this image we would need to:

- Partition the disk
- Write this data to the partition
- Install a boot loader

With all of this in mind, it becomes much simpler to convert the `qcow2` image and simply write it to disk.

## Using a Docker Image

We can easily make use of the **official** Docker images to generate a root filesystem for use when deploying with Tinkerbell.

### Downloading the Image

```
TMPRFS=$(docker container create ubuntu:latest)
docker export $TMPRFS > ubuntu_rootfs.tar
docker rm $TMPRFS
```

**Optional** - You can compress this raw image to save on both local disk space and network bandwidth when deploying the image.

```
gzip ./ubuntu_rootfs.tar
```

Move the raw image to a locally accessible web server. To simplify, you can place the image in the Tinkerbell sandbox webroot, which allows access to the image at the IP address of the `tink-server`. 

```
mv ./ubuntu_rootfs.tar.gz ./sandbox/deploy/state/webroot
```

### Creating the Template

The template makes use of the actions from the artifact hub.

- [rootio](https://artifacthub.io/packages/tbaction/tinkerbell-community/rootio) - to partition our disk and make filesystems.
- [archive2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/archive2disk) - to write the OS image to a block device.
- [cexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/cexec) - to run commands inside (chroot) our newly provisioned operating system.
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned operating system. 

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
	  - name: "expand-ubuntu-filesystem-to-root"
	    image: quay.io/tinkerbell-actions/archive2disk:v1.0.0
	    timeout: 90
	    environment:
		    ARCHIVE_URL: http://192.168.1.1:8080/ubuntu_rootfs.tar.gz
		    ARCHIVE_TYPE: targz
		    DEST_DISK: /dev/sda3
		    FS_TYPE: ext4
		    DEST_PATH: /
      - name: "install-grub-bootloader"
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
