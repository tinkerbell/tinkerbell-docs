---
title: Example - Windows
date: 2021-03-24
---

# Deploying Windows

This is a guide which walks through the process of deploying various Windows versions from an operating system image.

## Generating the Images

The [tinkerbell] GitHub organization contains a project called [crocodile] that largely automates the entire process of image creation.

The pre-requisites for using the `crocodile` project are:

- git
- Docker

It currently can build the following versions of Windows Operating System images:

- Windows 10
- Windows Server 2012
- Windows Server 2016
- Windows Server 2019

### Downloading `crocodile`

First, clone the repo:

```sh
git clone https://github.com/tinkerbell/crocodile
```

Then, move to the builder directory:

```sh
cd crocodile
```

### Building the Image Builder

The `docker build` command will create a local container called `croc:latest` that has everything required to build our Operating System images.

```sh
docker build -t croc .
```

### Creating an Image

Run `docker run`.

```sh
docker run -it --rm \
	-v $PWD/packer_cache:/packer/packer_cache \
	-v $PWD/images:/var/tmp/images \
	--net=host \
	--device=/dev/kvm \
	croc:latest
```

The command will create the a `packer_cache` folder and an `images` folder in the current folder.
These folders will be used for assets and the built OS images, respectively.

```text
                          .--.  .--.
                         /    \/    \
                        | .-.  .-.   \
                        |/_  |/_  |   \
                        || `\|| `\|    `----.
                        |\0_/ \0_/    --,    \_
      .--"""""-.       /              (` \     `-.
     /          \-----'-.              \          \
     \  () ()                         /`\          \
     |                         .___.-'   |          \
     \                        /` \|      /           ;
      `-.___             ___.' .-.`.---.|             \
         \| ``-..___,.-'`\| / /   /     |              `\
          `      \|      ,`/ /   /   ,  /
                  `      |\ /   /    |\/
                   ,   .'`-;   '     \/
              ,    |\-'  .'   ,   .-'`
            .-|\--;`` .-'     |\.'
           ( `"'-.|\ (___,.--'`'
            `-.    `"`          _.--'
               `.          _.-'`-.
                 `''---''``       `."
Select "quit"  when you've finished building Operating Systems
1) windows-2012
2) windows-2016
3) windows-2019
4) windows-10
5) quit
```

Select the Operating System you'd like to build and the entire process will begin, including downloading of the required ISO's and configuring of the Operating Systems.

When it finishes, the newly built Windows Operating Systems will exist in the `images` folder.

## Creating the Template

First, the template will need a custom action to reboot the system into the new Operating System after it's written to the device.

### Creating a `reboot` action `Dockerfile`

In a different folder create a `Dockerfile` with the following contents:

```dockerfile
FROM busybox
ENTRYPOINT [ "touch", "/worker/reboot" ]
```

Then, build the new action and push it to the local registry.

```sh
docker build -t local-registry/reboot:1.0 .
```

Once the new action is pushed to the local registry, it can be used as an action in a template.

```yaml
actions:
- name: "reboot"
  image: local-registry/reboot:1.0
  timeout: 90
  volumes:
	- /worker:/worker
```

### The Example Template

The template uses actions from the [Artifact Hub].

- [image2disk] - to write the image to a block device.
- Our custom action that will cause a system reboot into our new Operating System.

> Important: Don't forget to pull, tag, and push `quay.io/tinkerbell-actions/image2disk:v1.0.0` prior to using it.

```yaml
version: "0.1"
name: Windows_deployment
global_timeout: 1800
tasks:
  - name: "os-installation"
	worker: "{{.device_1}}"
	volumes:
	  - /dev:/dev
	  - /dev/console:/dev/console
	  - /lib/firmware:/lib/firmware:ro
	actions:
      - name: "stream-Windows-image"
        image: quay.io/tinkerbell-actions/image2disk:v1.0.0
		timeout: 600
		environment:
		  DEST_DISK: /dev/sda
		  IMG_URL: "http://192.168.1.1:8080/tink-windows-2016.raw.gz"
		  COMPRESSED: true
      - name: "reboot into Windows"
        image: local-registry/reboot:1.0
        timeout: 90
        volumes:
	    - /worker:/worker
```

[artifact hub]: https://artifacthub.io/packages/search?kind=4
[crocodile]: https://github.com/tinkerbell/crocodile
[image2disk]: https://artifacthub.io/packages/tbaction/tinkerbell-community/image2disk
[tinkerbell]: https://tinkerbell.org
