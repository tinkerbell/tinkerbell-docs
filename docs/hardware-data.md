---
title: Hardware Data
date: 2019-01-04
---

# Hardware Data

- Hardware data holds the details about the hardware that you wish to use with a workflow.
- A hardware may have multiple network devices that can be used in a worklfow.
- The details about all those devices is maintained in JSON format as hardware data.

## Example

If you have a hardware that has a single network/worker device on it, its hardware data shall be structured like the following:

```json
{
  "id": "0eba0bf8-3772-4b4a-ab9f-6ebe93b90a94",
  "metadata": {
    "bonding_mode": 5,
    "custom": {
      "preinstalled_operating_system_version": {},
      "private_subnets": []
    },
    "facility": {
      "facility_code": "ewr1",
      "plan_slug": "c2.medium.x86",
      "plan_version_slug": ""
    },
    "instance": {
      "crypted_root_password": "redacted",
      "operating_system_version": {
        "distro": "ubuntu",
        "os_slug": "ubuntu_18_04",
        "version": "18.04"
      },
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
    },
    "manufacturer": {
      "id": "",
      "slug": ""
    },
    "state": ""
  },
  "network": {
    "interfaces": [
      {
        "dhcp": {
          "arch": "x86_64",
          "hostname": "server001",
          "ip": {
            "address": "192.168.1.5",
            "gateway": "192.168.1.1",
            "netmask": "255.255.255.248"
          },
          "lease_time": 86400,
          "mac": "00:00:00:00:00:00",
          "name_servers": [],
          "time_servers": [],
          "uefi": false
        },
        "netboot": {
          "allow_pxe": true,
          "allow_workflow": true,
          "ipxe": {
            "contents": "#!ipxe",
            "url": "http://url/menu.ipxe"
          },
          "osie": {
            "base_url": "",
            "initrd": "",
            "kernel": "vmlinuz-x86_64"
          }
        }
      }
    ]
  }
}
```

## Property Description

The following section explains each property in the above example:

| Property                                                     | Description                                                                                                                                                                                                                                                                                 |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| id                                                           | A UUID used to uniquely identify the hardware. The `id` can be generated using the `uuidgen` command. If you are in Equinix Metal environment, you can get the `id` from the server overview page.                                                                                          |
| network                                                      | Network details                                                                                                                                                                                                                                                                             |
| network.Interfaces[]                                         | List of network interfaces on the hardware                                                                                                                                                                                                                                                  |
| network.interfaces[].dhcp                                    | DHCP details                                                                                                                                                                                                                                                                                |
| network.interfaces[].dhcp.mac                                | MAC address of the network device (worker)                                                                                                                                                                                                                                                  |
| network.interfaces[].dhcp.ip                                 | IP details for DHCP                                                                                                                                                                                                                                                                         |
| network.interfaces[].dhcp.ip.address                         | Worker IP address to be requested over DHCP                                                                                                                                                                                                                                                 |
| network.interfaces[].dhcp.ip.gateway                         | Gateway address                                                                                                                                                                                                                                                                             |
| network.interfaces[].dhcp.ip.netmask                         | Netmask for the private network                                                                                                                                                                                                                                                             |
| network.interfaces[].dhcp.hostname                           | Hostname                                                                                                                                                                                                                                                                                    |
| network.interfaces[].dhcp.lease_time                         | Expiration in secs (default: 86400)                                                                                                                                                                                                                                                         |
| network.interfaces[].dhcp.name_servers[]                     | DNS servers                                                                                                                                                                                                                                                                                 |
| network.interfaces[].dhcp.time_servers[]                     | NTP servers                                                                                                                                                                                                                                                                                 |
| network.interfaces[].dhcp.arch                               | Hardware architecture, example: `x86_64`                                                                                                                                                                                                                                                    |
| network.interfaces[].dhcp.uefi                               | Is UEFI                                                                                                                                                                                                                                                                                     |
| network.interfaces[].netboot                                 | Netboot details                                                                                                                                                                                                                                                                             |
| network.interfaces[].netboot.allow_pxe                       | Must be set to `true` to PXE.                                                                                                                                                                                                                                                               |
| network.interfaces[].netboot.allow_workflow                  | Must be `true` in order to execute a workflow.                                                                                                                                                                                                                                              |
| network.interfaces[].netboot.ipxe                            | Details for iPXE                                                                                                                                                                                                                                                                            |
| network.interfaces[].netboot.ipxe.url                        | iPXE script URL                                                                                                                                                                                                                                                                             |
| network.interfaces[].netboot.ipxe.contents                   | iPXE script contents                                                                                                                                                                                                                                                                        |
| network.interfaces[].netboot.osie                            | OSIE details                                                                                                                                                                                                                                                                                |
| network.interfaces[].netboot.osie.kernel                     | Kernel                                                                                                                                                                                                                                                                                      |
| network.interfaces[].netboot.osie.initrd                     | Initrd                                                                                                                                                                                                                                                                                      |
| network.interfaces[].netboot.osie.base_url                   | Base URL for the kernel and initrd                                                                                                                                                                                                                                                          |
| metadata                                                     | Hardware metadata details                                                                                                                                                                                                                                                                   |
| metadata.state                                               | State must be set to `provisioning` for workflows.                                                                                                                                                                                                                                          |
| metadata.bonding_mode                                        | Bonding mode                                                                                                                                                                                                                                                                                |
| metadata.manufacturer                                        | Manufacturer details                                                                                                                                                                                                                                                                        |
| metadata.instance                                            | Holds the details for an instance                                                                                                                                                                                                                                                           |
| metadata.instance.storage                                    | Details for an instance storage like disks and filesystems                                                                                                                                                                                                                                  |
| metadata.instance.storage.disks                              | List of disk partitions                                                                                                                                                                                                                                                                     |
| metadata.instance.storage.disks[].device                     | Name of the disk                                                                                                                                                                                                                                                                            |
| metadata.instance.storage.disks[].wipe_table                 | Set to `true` to allow disk wipe.                                                                                                                                                                                                                                                           |
| metadata.instance.storage.disks[].partitions                 | List of disk partitions                                                                                                                                                                                                                                                                     |
| metadata.instance.storage.disks[].partitions[].size          | Size of the partition                                                                                                                                                                                                                                                                       |
| metadata.instance.storage.disks[].partitions[].label         | Partition label like BIOS, SWAP or ROOT                                                                                                                                                                                                                                                     |
| metadata.instance.storage.disks[].partitions[].number        | Partition number                                                                                                                                                                                                                                                                            |
| metadata.instance.storage.filesystems                        | List of filesystems and their respective mount points                                                                                                                                                                                                                                       |
| metadata.instance.storage.filesystems[].mount                | Details about the filesystem to be mounted                                                                                                                                                                                                                                                  |
| metadata.instance.storage.filesystems[].mount.point          | Mount point for the filesystem                                                                                                                                                                                                                                                              |
| metadata.instance.storage.filesystems[].mount.create         | Additional details that can be provided while creating a partition                                                                                                                                                                                                                          |
| metadata.instance.storage.filesystems[].mount.create.options | Options to be passed to `mkfs` while creating a partition                                                                                                                                                                                                                                   |
| metadata.instance.storage.filesystems[].mount.device         | Device to be mounted                                                                                                                                                                                                                                                                        |
| metadata.instance.storage.filesystems[].mount.format         | Filesystem format                                                                                                                                                                                                                                                                           |
| metadata.instance.crypted_root_password                      | Hash for root password that is used to login into the worker after provisioning. The hash can be generated using the `openssl passwd` command. For example, `openssl passwd -6 -salt xyz your-password`.                                                                                    |
| metadata.operating_system_version                            | Details about the operating system to be installed                                                                                                                                                                                                                                          |
| metadata.operating_system_version.distro                     | Operating system distribution name, like ubuntu                                                                                                                                                                                                                                             |
| metadata.operating_system_version.version                    | Operating system version, like 18.04 or 20.04                                                                                                                                                                                                                                               |
| metadata.operating_system_version.os_slug                    | A slug is a combination of operating system distro and version.                                                                                                                                                                                                                             |
| metadata.facility                                            | Facility details                                                                                                                                                                                                                                                                            |
| metadata.facility.plan_slug                                  | The slug for the worker class. The value for this property depends on how you setup your workflow. While it is required if you are using the OS images from [packet-images](https://github.com/packethost/packet-images) repository, it may be left out if not used at all in the workflow. |
| metadata.facility.facility_code                              | For local setup, `onprem` or any other string value can be used.                                                                                                                                                                                                                            |

## The Minimal Hardware Data

While the hardware data is essential, not all the properties are required for every workflow.
In fact, it's upto a workflow designer how they want to use the data in their workflow.
Therefore, you may start with the minimal data given below and only add the properties you would want to use in your workflow.

```json
{
  "id": "0eba0bf8-3772-4b4a-ab9f-6ebe93b90a94",
  "metadata": {
    "facility": {
      "facility_code": "ewr1",
      "plan_slug": "c2.medium.x86",
      "plan_version_slug": ""
    },
    "instance": {},
    "state": "provisioning"
  },
  "network": {
    "interfaces": [
      {
        "dhcp": {
          "arch": "x86_64",
          "ip": {
            "address": "192.168.1.5",
            "gateway": "192.168.1.1",
            "netmask": "255.255.255.248"
          },
          "mac": "00:00:00:00:00:00",
          "uefi": false
        },
        "netboot": {
          "allow_pxe": true,
          "allow_workflow": true
        }
      }
    ]
  }
}
```
