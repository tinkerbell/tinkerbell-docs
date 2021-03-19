---
title: Examples: RedHat Enterprise Linux & CentOS
date: 2021-03-16
---

# Deploying RHEL/CentOS

This is a guide which walks through the process of deploying either RHEL or CentOS through a number of different mechanisms:

- Operating System Image
- Docker Images

## Operating System Image (CentOS)

**NOTE** CentOS 8 is the last release and will be going EOL at the end of 2021.

The CentOS project provide cloud images in a number of different formats, however or the purposes of usage with Tinkerbell only the `qcow2` format is an option. The CentOS images are available the `cloud-images` web site [https://cloud.centos.org/centos/8/x86_64/images/](https://cloud.centos.org/centos/8/x86_64/images/).

Below are two examples of images we can use:
```
CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2	2020-06-11 02:51	1.1G	 
CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2	2020-12-04 17:51	1.2G	 
```

Both images are a `qcow2` filesystem image which is a **full** disk image including partition tables, partitions filled with filesystems, files and importantly a boot loader at the begging of the disk image.

## Operating System Image (RHEL)

RedHat provide RHEL Operating System images in the `qcow2` format, however in order to download a RHEL image a "Red Hat Account" is required. More information is available at [https://access.redhat.com/solutions/641193](https://access.redhat.com/solutions/641193)

The cloud images can be found at (login required): 

RHEL8: [https://access.redhat.com/downloads/content/479/ver=/rhel—8/8.0/x86_64/product-software](https://access.redhat.com/downloads/content/479/ver=/rhel—8/8.0/x86_64/product-software)
RHEL7: [https://access.redhat.com/downloads/content/69/ver=/rhel—7/7.1/x86_64/product-downloads](https://access.redhat.com/downloads/content/69/ver=/rhel—7/7.1/x86_64/product-downloads)

## Fedora CoreOS

Additionally following the acquisition of CoreOS by RedHat, there is an additional Operating System distributed by RedHat called Fedora CoreOS, that is available at [https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=stable](https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=stable). 

This Operating System is distributed in a number of formats:

```
fedora-coreos-33.20210217.3.0-metal.x86_64.qcow2.xz
fedora-coreos-33.20210217.3.0-metal.x86_64.raw.xz
```

Both images come with compressed with the `xz` compression format, we can decompress these image with the the command `xz -d <file.xz>`.

The first image (with the extension `.qcow2.xz`) is actually a compressed `qcow2` filesystem image and is a **full** disk image including partition tables, partitions filled with filesystems, files and importantly a boot loader at the begging of the disk image. 

 The second image is a disk image, in particular it contains a full partition table (including OS and Swap partition) and boot loader for our Fedora CoreOS system.

### Convert QCOW2 Image 

To convert our image to disk we will need to install the `qemu-img` cli tool.

`apt-get install -y qemu-utils`

We can now use this tool to convert our image into a `raw` filesystem:

`qemu-img convert  ./CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2 -O raw ./CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.raw`

**Optionally** we can compress this raw image to save on both local disk space and network bandwidth when deploying the image.

`gzip ./CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.raw`

The raw image will now need moving to a locally accessible web server, we can place our image into the Tinkerbell sandbox webroot to simplify this usage. This will allow us to access our images at the IP address of the `tink-server`. 

`mv ./CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.raw.gz ./sandbox/deploy/state/webroot`

### Writing our workflow

This example will use the CentOS images, so please modify for other distributions such as RHEL or Fedora CoreOS.

Our workflow will make use of the actions from the [artifact.io](https://artifact.io) hub:

- [image2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/image2disk) - to write the OS image to a block device
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned Operating System 

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
			http://192.168.1.2/CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.raw.gz
		  COMPRESSED: true
	  - name: kexec
		image: 'quay.io/tinkerbell-actions/kexec:v1.0.0'
		timeout: 90
		pid: host
		environment:
		  BLOCK_DEVICE: /dev/sda1
		  FS_TYPE: ext4
```

## Docker Image for CentOS

 We can easily make use of the **official** docker images to generate a root filesystem for use when deploying with Tinkerbell

### Download CentOS image as root filesystem

 ```
 TMPRFS=$(docker container create centos:8)
 docker export $TMPRFS > centos_rootfs.tar
 docker rm $TMPRFS
 ```

 **Optionally** we can compress this filesystem archive to save on both local disk space and network bandwidth when deploying the image.

 `gzip ./centos_rootfs.tar`

 The raw image will now need moving to a locally accessible web server, we can place our image into the Tinkerbell sandbox webroot to simplify this usage. This will allow us to access our images at the IP address of the `tink-server`. 

 `mv ./centos_rootfs.tar.gz ./sandbox/deploy/state/webroot`

### Create CentOS workflow

 Our workflow will make use of the actions from the artifact hub:

 - [rootio](https://artifacthub.io/packages/tbaction/tinkerbell-community/rootio) - to partition our disk and make filesystems
 - [archive2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/archive2disk) - to write the OS image to a block device
 - [cexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/cexec) - to run commands inside (chroot) our newly provisioned Operating System
 - [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned Operating System 

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
			ARCHIVE_URL: 'http://192.168.1.2/centos_rootfs.tar.gz'
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
 
 
## Docker Image for RedHat Enterprise Linux
 
  We can easily make use of the **official** docker images to generate a root filesystem for use when deploying with Tinkerbell
 

### Download RHEL image as root filesystem
 
  ```
  TMPRFS=$(docker container create registry.access.redhat.com/rhel7:latest)
  docker export $TMPRFS > rhel_rootfs.tar
  docker rm $TMPRFS
  ```
 
**Optionally** we can compress this filesystem archive to save on both local disk space and network bandwidth when deploying the image.
 
`gzip ./rhel_rootfs.tar`
 
The raw image will now need moving to a locally accessible web server, we can place our image into the Tinkerbell sandbox webroot to simplify this usage. This will allow us to access our images at the IP address of the `tink-server`. 
 
`mv ./rhel_rootfs.tar.gz ./sandbox/deploy/state/webroot`
 
### Create RHEL workflow
 
Our workflow will make use of the actions from the artifact hub:
 
  - [rootio](https://artifacthub.io/packages/tbaction/tinkerbell-community/rootio) - to partition our disk and make filesystems
  - [archive2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/archive2disk) - to write the OS image to a block device
  - [cexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/cexec) - to run commands inside (chroot) our newly provisioned Operating System
  - [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned Operating System 
 
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
			ARCHIVE_URL: 'http://192.168.1.2/rhel_rootfs.tar.gz'
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
 
 
