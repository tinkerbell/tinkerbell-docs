---
title: Examples: FreeBSD
date: 2021-03-12
---

# Deploying FreeBSD

This is a guide which walks through the process of deploying FreeBSD through a number of different mechanisms:

- Operating System Image

## Operating System Image

FreeBSD distribute their Operating System in a number of different formats, which are all available on the `cloud-images` web site [https://download.freebsd.org/ftp/releases/VM-IMAGES/12.2-RELEASE/amd64/Latest/](https://download.freebsd.org/ftp/releases/VM-IMAGES/12.2-RELEASE/amd64/Latest/). 

Below are two examples of images we can use:

```
FreeBSD-12.2-RELEASE-amd64.qcow2.xz	599212960	2020-Oct-23 06:27
FreeBSD-12.2-RELEASE-amd64.raw.xz	600337912	2020-Oct-23 06:44
```

Both images come with compressed with the `xz` compression format, we can decompress these image with the the command `xz -d <file.xz>`

The first image (with the extension `.qcow2.xz`) is actually a compressed `qcow2` filesystem image and is a **full** disk image including partition tables, partitions filled with filesystems, files and importantly a boot loader at the begging of the disk image. 

The second image is a disk image, in particular it contains a full partition table (including OS and Swap partition) and boot loader for our FreeBSD system. (We can examine this with `losetup`)

```
$ losetup -f -P ./FreeBSD-12.2-RELEASE-amd64.raw 

$ fdisk -l /dev/loop1

Disk /dev/loop1: 5 GiB, 5369587712 bytes, 10487476 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 2346CB62-14FB-11EB-9C6B-0CC47AD8B808

Device         Start      End Sectors  Size Type
/dev/loop1p1       3      113     111 55.5K FreeBSD boot
/dev/loop1p2     114     1713    1600  800K EFI System
/dev/loop1p3    1714  2098865 2097152    1G FreeBSD swap
/dev/loop1p4 2098866 10487473 8388608    4G FreeBSD UFS
```

The `raw` image comes with everything that we will need to install and deploy FreeBSD, however if you need to convert the `qcow2` image then the steps are below.

### Convert Image 

To convert our image to disk we will need to install the `qemu-img` cli tool.

`apt-get install -y qemu-utils`

We can now use this tool to convert our image into a `raw` filesystem:

`qemu-img convert  ./FreeBSD-12.2-RELEASE-amd64.qcow2 -O raw ./FreeBSD-12.2-RELEASE-amd64.raw`

**Optionally** we can compress this raw image to save on both local disk space and network bandwidth when deploying the image.

`gzip ./FreeBSD-12.2-RELEASE-amd64.raw`

The raw image will now need moving to a locally accessible web server, we can place our image into the Tinkerbell sandbox webroot to simplify this usage. This will allow us to access our images at the IP address of the `tink-server`. 

`mv ./FreeBSD-12.2-RELEASE-amd64.raw.gz ./sandbox/deploy/state/webroot`

### Writing our workflow

Our workflow will make use of the actions from the [artifact.io](https://artifact.io) hub:

- [image2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/image2disk) - to write the OS image to a block device
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned Operating System 

```
version: "0.1"
name: FreeBSD_deployment
global_timeout: 1800
tasks:
  - name: "os-installation"
	worker: "{{.device_1}}"
	volumes:
	  - /dev:/dev
	  - /dev/console:/dev/console
	  - /lib/firmware:/lib/firmware:ro
	actions:
      - name: "stream FreeBSD image"
        image: quay.io/tinkerbell-actions/image2disk:v1.0.0
		timeout: 600
		environment:
		  DEST_DISK: /dev/sda
		  IMG_URL: "http://192.168.1.2/FreeBSD-12.2-RELEASE-amd64.raw.gz"
		  COMPRESSED: true
      - name: "kexec FreeBSD"
	    image: quay.io/tinkerbell-actions/kexec:v1.0.0
	    timeout: 90
	    pid: host
	    environment:
    	  BLOCK_DEVICE: /dev/sda1
	  	  FS_TYPE: ext4
```

