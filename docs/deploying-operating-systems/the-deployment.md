---
title: The Deployment
date: 2021-02-19
---

# The Deployment

In the majority of cases there will be a number of steps required before we're able to deploy an Operating System to a new piece of hardware. Which steps are largely dependent on the type or format of the Operating System deployment media that the provider distributes or which installation method you want to use.

## Using an OS Image

Not all Operating System images are distributed in the same formats, and in most use-cases either pre-preperation or conversion to a supported image type will be required. 

### Preparing the Image

A large number of Operating System vendors tend to distribute their images using the [qcow](https://en.wikipedia.org/wiki/Qcow) format, which comes from the Qemu virtualisation project. This provides a number of features that end users find desirable:

- Small image size (an image is typically only as large as the data written, not the size of the logical block device)
- The image can be used directly by the qemu/kvm hypervisor (used by a number of cloud providers)
- The `qcow` image can be easily converted to other formats.

The qemu project provides a number of useful tools to manage Operating System image files, the [qemu-image](https://en.wikibooks.org/wiki/QEMU/Images#Copying_an_image_to_a_physical_device) tool is commonly used to create/convert disk images.

We can convert a `qcow` image to a `raw` image with the following command:

```
qemu-img convert -O raw diskimage.qcow2 diskimage.raw
```

One drawback of this is that a `qcow` image will only occupy the space where data has been written, so if we had a 20G disk image and installed an OS that only used 1G the image size would be the 1G of data. **However**, when we move to a `raw` image then the image will occupy all of the disk image size regardless of the contents.

### Streaming the Image to Disk

Once you have your OS image prepared, use an action to write it directly to an underlying block device, which would effectively provision the Operating System to the hardware allowing us to reboot into this new OS. The [`image2disk`](https://artifacthub.io/packages/tbaction/tinkerbell-community/image2disk) action is designed for this use-case and has the capability to stream an Operating System image from a remote location over HTTP/HTTPS and write it directly to a specified block device.

For example, you can stream a raw Ubuntu image from a web-server and write the OS image to the block device `/dev/sda`.

```
actions:
- name: "stream ubuntu"
  image: quay.io/tinkerbell-actions/image2disk:v1.0.0
  timeout: 90
  environment:
      IMG_URL: 192.168.1.1:8080/ubuntu.raw
      DEST_DISK: /dev/sda
```

`image2disk` also supports on-the-fly gzip streaming, which allows you to compress the raw image using [gzip](https://en.wikipedia.org/wiki/Gzip) to save local disk space **and** the amount of network traffic to the hosts that are being provisioned.

```
gzip diskimage.raw
```

The resulting file `diskimage.raw.gz` in most cases will be smaller than the original qcow file.

You can then use the `image2disk` action to stream the image to the block device.

```
actions:
- name: "stream ubuntu"
  image: quay.io/tinkerbell-actions/image2disk:v1.0.0
  timeout: 90
  environment:
      IMG_URL: http://192.168.1.1:8080/ubuntu.tar.gz
      DEST_DISK: /dev/sda
      COMPRESSED: true
```

## Using a Filesystem Archive

### Formatting a Block Device

When provisioning from a filesystem archive, there is a **pre-requisite** for the block device to be partitioned and formatted with a filesystem before we can write files and directories to the storage. In Tinkerbell we specify in hardware data the configuration for the storage. For example, the following snippet details the configuration for the block device `/dev/sda`. There are three partitions that will be created and labeled. It also specifies the format and filesystem type for two of those partitions.

```
"storage": {
  "disks": [
	  {
		"device": "/dev/sda",
		"partitions": [
		  {
			"label": "BIOS",
			"number": 1,
			"size": 4096
		  },
		  {
			"label": "SWAP",
			"number": 2,
			"size": 3993600
		  },
		  {
			"label": "ROOT",
			"number": 3,
			"size": 0
		  }
		],
		"wipe_table": true
	  }
	],
	"filesystems": [
	  {
		"mount": {
		  "create": {
			"options": ["-L", "ROOT"]
		  },
		  "device": "/dev/sda3",
		  "format": "ext4",
		  "point": "/"
		}
	  },
	  {
		"mount": {
		  "create": {
			"options": ["-L", "SWAP"]
		  },
		  "device": "/dev/sda2",
		  "format": "swap",
		  "point": "none"
	  }
	}
  ]
}
```

> More information about block device configuration is on the Equinix Metal™[Custom Partitioning & Raid](https://metal.equinix.com/developers/docs/servers/custom-partitioning-raid/) page.

The example blob is just the description of the device in hardware data, we will also need an action during provisioning to parse this metadata and actually write these changes to the block device. This is the job of the [rootio](https://artifacthub.io/packages/tbaction/tinkerbell-community/rootio) action.

```
actions:
- name: "format"
  image: quay.io/tinkerbell-actions/rootio:v1.0.0
  timeout: 90
  command: ["format"]
  environment:
	  MIRROR_HOST: 192.168.1.2
```

Once this action has completed we will have successfully modified the underlying block device to have our storage configuration!

### Extracting the OS to the Filesystem

As detailed in [The Basics of Deploying an Operating System](https://docs.tinkerbell.org/deploying-operating-systems/the-basics/#filesystem-archives), we can download or create a filesystem archive in a number of different ways. Once we have a compressed archive of all of the files that make up the Operating System, we will again need to use an action to manage the task of fetching the archive and extracting it to our newly formatted file system. The action [archive2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/archive2disk) has the functionality to **mount** a filesystem and both **stream**/**extract** a filesystem archive directly to the new filesystem. 

```
actions:
- name: "expand ubuntu filesystem to root"
  image: quay.io/tinkerbell-actions/archive2disk:v1.0.0
  timeout: 90
  environment:
	  ARCHIVE_URL: http://192.168.1.1:8080/ubuntu.tar.gz
	  ARCHIVE_TYPE: targz
	  DEST_DISK: /dev/sda3
	  FS_TYPE: ext4
	  DEST_PATH: /
```

### Installing a Boot Loader

Whilst we may have deployed a full Operating System to our persistent storage, it will be rendered useless at a *reboot* unless we install a boot loader so that the machine knows how to load this new OS. We can automate this process by providing another action whose role would be to execute a command such as `grub-install` or `sysinux` to write the bootloader code to the beginning of the block device where the BIOS knows where to look for it on machine startup.

## Using an Installer

Some Operating Systems may require a combination of the two above examples for deployment, however there are other Operating Systems that can also be deployed through the use of an installer. 

These typically will require an installer binary to exist, as well as:

- It may require an action to write the installer binary to persistent storage for it to be ran.
- An action (docker container) may have all of the relevant files required to execute an installer.

### Debian example

`Dockerfile`

```
FROM debian:bullseye
RUN apt-get update; apt-get install -y grml-debootstrap
ENTRYPOINT ["grml-debootstrap", "--target", "/dev/sda3", "--grub", "/dev/sda"]
```

We can create an action from our Dockerfile:

```
docker build -t local-registry/debian:example .
```

Once we have pushed our new action to the registry we can reference the action in a workflow as shown below.

```
actions:
- name: "expand ubuntu filesystem to root"
  image: local-registry/debian:example
  timeout: 90
```

### Additional Bootstraps

- [Ubuntu](https://help.ubuntu.com/lts/installation-guide/armhf/apds04.html)
- [Centos/Rhel](https://github.com/dozzie/yumbootstrap)

## Next Steps

Once an Operating System image **or** a filesystem + bootloader is deployed we may need to customize it or boot into our new system, we can either `reboot` the host or `kexec` directly into the new OS.
