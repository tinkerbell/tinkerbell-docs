---
title: Creating a Basic Action
date: 2021-02-15
---

# Creating a Basic Action

This guide will step through creating a basic action, whilst also discussing a number of things an action builder should be aware of.

## Basic principles for an action

Ideally when creating an action it should follow a few basic principles:

- Minimal image size (action images need to be downloaded to `tmpfs` and will use the servers memory both at rest and runtime)
- Single use, one action should not try to do all things. Actions should follow the linux philosophy of do one thing, and do one thing well.
- Image re-use, where possible an image should be both simple and single-use but have the ability to be customised for other users.
- Chain together well with other actions, most actions will store in-use data on `/statedir`. Keeping with these standards ensures other actions know where to find this persistent data.
- Fail on unrecoverable error, an action when it encounters a point it can't continue should fail (with sufficient logging). No other changes should occur allowing the Tinkerbell operator the capability to debug why this failure has taken place.

## Our example action

A common task is manipulating the filesystem of the newly provisioned Operating System, there are numerous reasons for this such as users, network config, ssh keys or other files that require change. This example will use bash to make it as simple as possible to understand, however the we're aiming to use Golang where possible for a lot of the tinkerbell actions on the [hub](https://github.com/tinkerbell/hub/tree/main/actions).

Our simple action will mount our newly provisioned Operating System, and [touch](https://www.tecmint.com/8-pratical-examples-of-linux-touch-command/) a file to a location that we have specified.

As this action will use bash, and require shelling out to a number of other commands we will start with one of the smallest "distro" images [alpine](https://alpinelinux.org).

We will pass three pieces of information as environment variables into this action:

- `BLOCK_DEVICE` the device with our filesystem created on it
- `FS_TYPE` the format of the filesystem
- `TOUCH_PATH` the path of the file to "touch"/create.

### `example_action.sh`

```
#!/bin/bash
set -x

# Check that the environment variable is set, so we know what device to mount
if [[ ! -v BLOCK_DEVICE ]]; then
  echo "BLOCK_DEVICE NEEDS SETTING"
  exit 1
fi

# Check for other variables FS_TYPE / TOUCH_PATH

# Mount the disk (set -x) will report failures
/usr/bin/mount -v -f ${FS_TYPE} ${BLOCK_DEVICE} /mnt

# Create our file
/usr/bin/touch /mnt/$TOUCH_PATH

echo "Succesfully created [$TOUCH_PATH]"
exit 0
```

### `Dockerfile`

```
FROM alpine:3.13.1
COPY /example_action.sh /
ENTRYPOINT ["/example_action.sh"]
```

### Creating our action

Create the image:

`docker build -t example_actions:v0.1 .`

Tag it to our local registry `192.168.1.1` and push it so that `tink-worker` can use it, if the worker has internet access then we can use a public registry such as Docker hub / quay.io etc..

`docker tag example_actions:v0.1 192.168.1.1\example_actions:v0.1`

We can now push/upload our new action to use in a workflow!

`docker push 192.168.1.1\example_actions:v0.1`

## Using our action

Following all the steps above we can now create an action in a workflow, this simple will just leave us with a file called "hello" left in `/tmp`.

```
actions:
- name: "Say Hello!"
  image: 192.168.1.1\example_actions:v0.1
  timeout: 90
  environment:
	  BLOCK_DEVICE: /dev/sda3
	  FS_TYPE: ext4
	  TOUCH_PATH: /tmp/hello
```

In an ideal scenario previous actions will do things such as wipe disks and create filesystems, allowing us to use the partition/filesystem in later actions.

## Further reading

The Tinkerbell community has created a number of actions that are available on the [Artifact Hub](https://artifacthub.io/packages/search?page=1&ts_query_web=Tinkerbell+Action). All of the source code for these actions are available on the GitHub repository for the [Tinkerbell Hub](https://github.com/tinkerbell/hub/tree/main/actions).
