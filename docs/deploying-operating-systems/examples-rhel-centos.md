---
title: Example - Red Hat Enterprise Linux and CentOS
date: 2021-03-16
---

# Deploying Red Hat Enterprise Linux or CentOS

This is a guide which walks through the process of deploying either Red Hat Enterprise Linux (RHEL) or CentOS from an operating system image or a Docker image.

## Using an Operating System Image 

RedHat provides both RHEL and CoreOS images in the RedHat provide RHEL Operating System images in the `qcow2` format.

The CentOS images are available the `cloud-images` web site [https://cloud.centos.org/centos/8/x86_64/images/](https://cloud.centos.org/centos/8/x86_64/images/).

RHEL images require a Red Hat Account in order to download, and are available at (login required): 

- RHEL8: [https://access.redhat.com/downloads/content/479/ver=/rhel—8/8.0/x86_64/product-software](https://access.redhat.com/downloads/content/479/ver=/rhel—8/8.0/x86_64/product-software)
- RHEL7: [https://access.redhat.com/downloads/content/69/ver=/rhel—7/7.1/x86_64/product-downloads](https://access.redhat.com/downloads/content/69/ver=/rhel—7/7.1/x86_64/product-downloads)

A `qcow2` filesystem image which is a **full** disk image including partition tables, partitions filled with filesystems and the files, and importantly, a boot loader at the beginning of the disk image. It will need to be converted to a `raw` filesystem image in order to use it.

### Converting Image 

In order to use this image, it needs to be converted into a `raw` filesystem. In order to do the conversion, install the `qemu-img` CLI tool.

```
apt-get install -y qemu-utils
```

Then, use the tool to convert the image into a `raw` filesystem. This example uses one of the CentOS images.

```
qemu-img convert  ./CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2 -O raw ./CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.raw
```

**Optional** - You can compress this raw image to save on both local disk space and network bandwidth when deploying the image.

```
gzip ./CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.raw
```

Move the raw image to a locally accessible web server. To simplify, you can place the image in the Tinkerbell sandbox webroot, which allows access to the image at the IP address of the `tink-server`.

```
mv ./CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.raw.gz ./sandbox/deploy/state/webroot
```

### Fedora CoreOS

CentOS 8 is the last release and will be going EOL at the end of 2021, but following the acquisition of CoreOS by Red Hat, they distribute an additional operating system called Fedora CoreOS. It is available at [https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=stable](https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=stable), and distributed in both `raw` and `qcow2` format. 

```
fedora-coreos-33.20210217.3.0-metal.x86_64.qcow2.xz
fedora-coreos-33.20210217.3.0-metal.x86_64.raw.xz
```

Both images come with compressed with the `xz` compression format. You can decompress these image with the `xz` command.

```
xz -d <file.xz>
```

The `raw` disk image contains a full partition table (including OS and Swap partition) and boot loader for our Fedora CoreOS system, and can be used without converting it first.

The `.qcow2.xz` image is a **full** disk image including partition tables, partitions filled with filesystems and the files, and importantly, a boot loader at the beginning of the disk image. It will need to be converted to a `raw` filesystem image in order to use it, like RHEL and CentOS.

### Creating the Template

The template uses actions from the [artifact.io](https://artifact.io) hub.

- [image2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/image2disk) - to write the OS image to a block device.
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned operating system.

The example template uses the CentOS images, but you can modify it for other the other distributions such as RHEL or Fedora CoreOS.

```
version: '0.1'
name: CentOS_Deployment
global_timeout: 1800
tasks:
  - name: os-installation
	worker: '{{.device_1}}'
	volumes:
	  - '/dev:/dev'
	  - '/dev/console:/dev/console'
	  - '/lib/firmware:/lib/firmware:ro'
	actions:
	  - name: stream image
		image: 'quay.io/tinkerbell-actions/image2disk:v1.0.0'
		timeout: 600
		environment:
		  DEST_DISK: /dev/sda
		  IMG_URL: >-
			http://192.168.1.1:8080/CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.raw.gz
		  COMPRESSED: true
	  - name: kexec
		image: 'quay.io/tinkerbell-actions/kexec:v1.0.0'
		timeout: 90
		pid: host
		environment:
		  BLOCK_DEVICE: /dev/sda1
		  FS_TYPE: ext4
```

## Using a Docker Image for CentOS

We can easily make use of the **official** docker images to generate a root filesystem for use when deploying with Tinkerbell.

### Downloading the CentOS Image

```
TMPRFS=$(docker container create centos:8)
docker export $TMPRFS > centos_rootfs.tar
docker rm $TMPRFS
```

**Optional** - You can compress this filesystem archive to save on both local disk space and network bandwidth when deploying the image.

```
gzip ./centos_rootfs.tar
```

Move the raw image to a locally accessible web server. To simplify, you can place the image in the Tinkerbell sandbox webroot, which allows access to the image at the IP address of the `tink-server`.

```
mv ./centos_rootfs.tar.gz ./sandbox/deploy/state/webroot
```

### Creating the CentOS Template

The template makes use of the actions from the artifact hub.

- [rootio](https://artifacthub.io/packages/tbaction/tinkerbell-community/rootio) - to partition our disk and make filesystems.
- [archive2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/archive2disk) - to write the OS image to a block device.
- [cexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/cexec) - to run commands inside (chroot) our newly provisioned operating system.
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned operating system.

```
version: '0.1'
name: debian_bullseye_provisioning
global_timeout: 1800
tasks:
  - name: os-installation
	worker: '{{.device_1}}'
	volumes:
	  - '/dev:/dev'
	  - '/dev/console:/dev/console'
	  - '/lib/firmware:/lib/firmware:ro'
	actions:
	  actions:
		- name: disk-wipe-partition
		  image: 'quay.io/tinkerbell-actions/rootio:v1.0.0'
		  timeout: 90
		  command:
			- partition
		  environment:
			MIRROR_HOST: 192.168.1.2
		- name: format
		  image: 'quay.io/tinkerbell-actions/rootio:v1.0.0'
		  timeout: 90
		  command:
			- format
		  environment:
			MIRROR_HOST: 192.168.1.2
		- name: expand debian filesystem to root
		  image: 'quay.io/tinkerbell-actions/archive2disk:v1.0.0'
		  timeout: 90
		  environment:
			ARCHIVE_URL: 'http://192.168.1.1:8080/centos_rootfs.tar.gz'
			ARCHIVE_TYPE: targz
			DEST_DISK: /dev/sda3
			FS_TYPE: ext4
			DEST_PATH: /
		- name: Install Grub Bootloader
		  image: 'quay.io/tinkerbell-actions/cexec:v1.0.0'
		  timeout: 90
		  environment:
			BLOCK_DEVICE: /dev/sda3
			FS_TYPE: ext4
			CHROOT: 'y'
			CMD_LINE: grub-install --root-directory=/boot /dev/sda
		- name: kexec-debian
		  image: 'quay.io/tinkerbell-actions/kexec:v1.0.0'
		  timeout: 600
		  environment:
			BLOCK_DEVICE: /dev/sda3
			FS_TYPE: ext4
```

 
## Using a Docker Image for Red Hat Enterprise Linux

We can easily make use of the **official** docker images to generate a root filesystem for use when deploying with Tinkerbell.

### Download the RHEL Image
 
```
TMPRFS=$(docker container create registry.access.redhat.com/rhel7:latest)
docker export $TMPRFS > rhel_rootfs.tar
docker rm $TMPRFS
```
 
**Optional** - You can compress this filesystem archive to save on both local disk space and network bandwidth when deploying the image.
 
```
gzip ./rhel_rootfs.tar
```
 
Move the raw image to a locally accessible web server. To simplify, you can place the image in the Tinkerbell sandbox webroot, which allows access to the image at the IP address of the `tink-server`. 
 
```
mv ./rhel_rootfs.tar.gz ./sandbox/deploy/state/webroot
```
 
### Creating the RHEL Template

The template makes use of the actions from the artifact hub.

- [rootio](https://artifacthub.io/packages/tbaction/tinkerbell-community/rootio) - to partition our disk and make filesystems.
- [archive2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/archive2disk) - to write the OS image to a block device.
- [cexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/cexec) - to run commands inside (chroot) our newly provisioned operating system.
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned operating system.
 
```
version: '0.1'
name: debian_bullseye_provisioning
global_timeout: 1800
tasks:
  - name: os-installation
	worker: '{{.device_1}}'
	volumes:
	  - '/dev:/dev'
	  - '/dev/console:/dev/console'
	  - '/lib/firmware:/lib/firmware:ro'
	actions:
	  actions:
		- name: disk-wipe-partition
		  image: 'quay.io/tinkerbell-actions/rootio:v1.0.0'
		  timeout: 90
		  command:
			- partition
		  environment:
			MIRROR_HOST: 192.168.1.2
		- name: format
		  image: 'quay.io/tinkerbell-actions/rootio:v1.0.0'
		  timeout: 90
		  command:
			- format
		  environment:
			MIRROR_HOST: 192.168.1.2
		- name: expand debian filesystem to root
		  image: 'quay.io/tinkerbell-actions/archive2disk:v1.0.0'
		  timeout: 90
		  environment:
			ARCHIVE_URL: 'http://192.168.1.1:8080/rhel_rootfs.tar.gz'
			ARCHIVE_TYPE: targz
			DEST_DISK: /dev/sda3
			FS_TYPE: ext4
			DEST_PATH: /
		- name: Install EPEL repo
		  image: 'quay.io/tinkerbell-actions/cexec:v1.0.0'
		  timeout: 90
		  environment:
			BLOCK_DEVICE: /dev/sda3
			FS_TYPE: ext4
			CHROOT: 'y'
			CMD_LINE: >-
			  curl -O
			  https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm;
			  yum install ./epel-release-latest-7.noarch.rpm; yum install grub2
		- name: Install Grub Bootloader
		  image: 'quay.io/tinkerbell-actions/cexec:v1.0.0'
		  timeout: 90
		  environment:
			BLOCK_DEVICE: /dev/sda3
			FS_TYPE: ext4
			CHROOT: 'y'
			CMD_LINE: grub-install --root-directory=/boot /dev/sda
		- name: kexec-debian
		  image: 'quay.io/tinkerbell-actions/kexec:v1.0.0'
		  timeout: 600
		  environment:
			BLOCK_DEVICE: /dev/sda3
			FS_TYPE: ext4
```
 
 
