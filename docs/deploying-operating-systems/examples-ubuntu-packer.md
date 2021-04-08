---
title: Examples - Deploying Ubuntu from Packer Machine image
date: 2021-04-02
---

# Deploying Ubuntu from Packer Machine Image

This guide will walk you through how you create a minimalistic raw Ubuntu image using [Packer](https://www.packer.io/), an awesome tool to build automated machine images. 

Currently, Packer does not officially provide a way to make bare metal machine images. So, in this example, we will use `virtualbox-iso` builder to create a Virtual Machine Disk (VDMK) and then convert it to a raw image.

The raw image can then be deployed on a bare metal server using Tinkerbell.

## Preseed and Config files for Ubuntu 20.04

Below are the preseed file and the config file for creating a minimalistic Ubuntu 20.04 image.

When building an image using `virtualbox-iso`, the [preseed file](https://www.packer.io/guides/automatic-operating-system-installs/preseed_ubuntu) will help with automating the deployment. It is placed inside the `http` directory, and the config file references the location of the preseed file in the `boot_command` list of the `builders` object.

- `pressed.cfg`

```
choose-mirror-bin mirror/http/proxy string
d-i base-installer/kernel/override-image string linux-server
d-i clock-setup/utc boolean true
d-i clock-setup/utc-auto boolean true
d-i finish-install/reboot_in_progress note
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i partman-auto/disk string /dev/sda
d-i partman-auto-lvm/guided_size string max
d-i partman-auto/choose_recipe select atomic
d-i partman-auto/method string lvm
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-lvm/device_remove_lvm boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman/confirm_write_new_label boolean true
d-i pkgsel/include string openssh-server cryptsetup build-essential libssl-dev libreadline-dev zlib1g-dev linux-source dkms nfs-common docker-compose
d-i pkgsel/install-language-support boolean false
d-i pkgsel/update-policy select none
d-i pkgsel/upgrade select full-upgrade
d-i time/zone string UTC
tasksel tasksel/first multiselect standard, ubuntu-server

d-i console-setup/ask_detect boolean false
d-i keyboard-configuration/layoutcode string us
d-i keyboard-configuration/modelcode string pc105
d-i debian-installer/locale string en_US.UTF-8

# Create vagrant user account.
d-i passwd/user-fullname string vagrant
d-i passwd/username string vagrant
d-i passwd/user-password password vagrant
d-i passwd/user-password-again password vagrant
d-i user-setup/allow-password-weak boolean true
d-i user-setup/encrypt-home boolean false
d-i passwd/user-default-groups vagrant sudo
d-i passwd/user-uid string 900
```

In config file, the builder type is set to `virtualbox-iso` to generate the VMDK and the post-processor type is set to `compress` to generate a `tar` file.

- `config.json`

```
{
  "builders": [
    {
      "boot_command": [
        "<esc><wait>",
        "<esc><wait>",
        "<enter><wait>",
        "/install/vmlinuz<wait>",
        " initrd=/install/initrd.gz",
        " auto-install/enable=true",
        " debconf/priority=critical",
        " netcfg/get_domain=vm<wait>",
        " netcfg/get_hostname=vagrant<wait>",
        " grub-installer/bootdev=/dev/sda<wait>",
        " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
        " -- <wait>",
        "<enter><wait>"
      ],
      "boot_wait": "10s",
      "guest_os_type": "ubuntu-64",
      "guest_additions_mode": "disable",
      "disk_size": 8192,
      "http_directory": "http",
      "iso_urls": [
        "ubuntu-18.04.5-server-amd64.iso",
        "http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/ubuntu-18.04.5-server-amd64.iso"
      ],
      "iso_checksum": "sha256:8c5fc24894394035402f66f3824beb7234b757dd2b5531379cb310cedfdf0996",
      "shutdown_command": "echo 'vagrant' | sudo -S shutdown -P now",
      "ssh_password": "vagrant",
      "ssh_username": "vagrant",
      "ssh_wait_timeout": "10000s",
      "type": "virtualbox-iso",
      "vm_name": "packer-ubuntu-64-20-04"
    }
  ],
  "post-processors": [
    {
      "type": "compress",
      "compression_level": 9,
      "output": "test.tar",
      "keep_input_artifact": true
    }
  ]
}
```

Both files are reference files, if you wish to modify something, you can make the changes accordingly. The steps to generate the image will remain the same.

The files will need to be placed in the directory structure of the Packer image builder.

```
ubuntu_packer_image
├── http
│   └── preseed.cfg
└── config.json
```

## Generating the VMDK

Run `packer build` to generate the VMDK and `tar` file. 

```
PACKER_LOG=1 packer build config.json
```

Setting `PACKER_LOG` will allow you to see the logs of the Packer build step.

When you run `packer build` with the example config file, the VMDK will be inside the output directory, while `tar` will be at the root directory.

## Converting the Image

Currently, the raw image can not be built directly from `virtualbox-iso` builder, so we will convert and then compress it. (If you are using `qemu` builder type instead of the `virtualbox-iso` builder, then you can skip the conversion step as Packer lets you directly create a raw image.)

First, get the `qemu-img` CLI tool.

```
apt-get install -y qemu-utils
```

Then use the tool to convert the VMDK into a `raw` filesystem.

```
qemu-img convert -f vmdk -o raw output-virtualbox-iso/packer-ubuntu-64-20.04-disk001.vmdk test_packer.raw
```

Once you have a `raw` filesystem image, you can compress the raw image.

```
gzip test_packer.raw
```

The result is a `test_packer.raw.gz` file which can now be deployed on Tinkerbell. You can also use the `raw` file `test_packer.raw` directly, the benefit of having the compressed file is that it will be streamed over the network in less time.

## Creating a Template

Below is a reference file for creating a Template using above Ubuntu Packer image. This section is similar to the other examples we have in the `Deploying Operating systems` section. You can follow them for more references.

The template uses actions from the [artifact.io](https://artifact.io) hub.

- [image2disk](https://artifacthub.io/packages/tbaction/tinkerbell-community/image2disk) - to write the OS image to a block device.
- [kexec](https://artifacthub.io/packages/tbaction/tinkerbell-community/kexec) - to `kexec` into our newly provisioned operating system.

```
version: "0.1"
name: Ubuntu_20_04
global_timeout: 1800
tasks:
  - name: "os-installation"
    worker: "{{.device_1}}"
    volumes:
      - /dev:/dev
      - /dev/console:/dev/console
      - /lib/firmware:/lib/firmware:ro
    actions:
      - name: "stream_ubuntu_packer_image"
        image: quay.io/tinkerbell-actions/image2disk:v1.0.0
        timeout: 600
        environment:
          DEST_DISK: /dev/sda
          IMG_URL: "http://192.168.1.1:8080/test_packer.raw.gz"
          COMPRESSED: true
      - name: "kexec_ubuntu"
        image: quay.io/tinkerbell-actions/kexec:v1.0.0
        timeout: 90
        pid: host
        environment:
          BLOCK_DEVICE: /dev/sda1
            FS_TYPE: ext4
```
