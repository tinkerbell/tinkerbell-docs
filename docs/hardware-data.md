---
title: Hardware Data
date: 2023-01-13
---

# Hardware Data

- Hardware data holds the details about the hardware that you wish to use with a workflow.
- A hardware may have multiple network devices that can be used in a worklfow.
- The details about all those devices is maintained in YAML format as hardware data.

## Example

You record Hardware data in a yaml file, the name of your choosing. It is advisable to reflect on a good naming convention that suits your 'datacentre' environment, as you may have many of these. For example, pod1machine1.yaml. The `facitity_code` and `hostname` could be good hints when considering such conventions.
If you have a hardware that has a single network/worker device on it, its hardware data shall be structured like the following:


```yaml

apiVersion: "tinkerbell.org/v1alpha1"
kind: Hardware
metadata:
  name: machine1
spec:
  disks:
    - device: $DISK_DEVICE
  metadata:
    facility:
      facility_code: sandbox
    instance:
      hostname: "machine1"
      id: "$TINKERBELL_CLIENT_MAC"
      operating_system:
        distro: "ubuntu"
        os_slug: "ubuntu_20_04"
        version: "20.04"
  interfaces:
    - dhcp:
        arch: x86_64
        hostname: machine1
        ip:
          address: $TINKERBELL_CLIENT_IP
          gateway: $TINKERBELL_CLIENT_GW
          netmask: 255.255.255.0
        lease_time: 86400
        mac: $TINKERBELL_CLIENT_MAC
        name_servers:
          - 1.1.1.1
          - 8.8.8.8
        uefi: false
      netboot:
        allowPXE: true
        allowWorkflow: true
```
The environment variable could be hard coded (and perhaps GitOps controlled), auto generated from your own personal scripts, or simply use values set in your shell. Irrespective, for the referenced we present some examplesthe mentioned represent:

## Property Description

The following section explains each property in the above example:

| Property                                                     | Description                                                                                                                                                                                                                                    |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| metadata.name                                                           | An string identifier used to uniquely identify the hardware. Uniqueness is critical here as this is used as a 'primary key' by kubernetes to connect with other relevant CRDs.                                          
| interfaces:                                         | List of network interfaces on the hardware                                                                                                                                                                                                     |
| interfaces[].dhcp                                    | DHCP details                                                                                                                                                                                                                                   |
| interfaces[].dhcp.mac                                | MAC address of the network device (worker)                                                                                                                                                                                                     |
| interfaces[].dhcp.ip                                 | IP details for DHCP                                                                                                                                                                                                                            |
| interfaces[].dhcp.ip.address                         | Worker IP address to be requested over DHCP                                                                                                                                                                                                    |
| interfaces[].dhcp.ip.gateway                         | Gateway address                                                                                                                                                                                                                                |
| interfaces[].dhcp.ip.netmask                         | Netmask for the private network                                                                                                                                                                                                                |
| interfaces[].dhcp.hostname                           | Hostname                                                                                                                                                                                                                                       |
| interfaces[].dhcp.lease_time                         | Expiration in secs (default: 86400)                                                                                                                                                                                                            |
| interfaces[].dhcp.name_servers[]                     | DNS servers                                                                                                                                                                                                                                    |
| interfaces[].dhcp.time_servers[]                     | NTP servers                                                                                                                                                                                                                                    |
| interfaces[].dhcp.arch                               | Hardware architecture, example: `x86_64`                                                                                                                                                                                                       |
| interfaces[].dhcp.uefi                               | Is UEFI                                                                                                                                                                                                                                        |
| interfaces[].netboot                                 | Netboot details                                                                                                                                                                                                                                |
| interfaces[].netboot.allow_pxe                       | Must be set to `true` to PXE.                                                                                                                                                                                                               
| metadata                                                     | Hardware metadata details                                                                                                                                                                                                                      |
| metadata.manufacturer                                        | Manufacturer details                                                                                                                                                                                                                           |
| metadata.instance                                            | Holds the details for an instance                                                                                                                                                                                                              |
| metadata.instance.operating_system.version                            | Details about the operating system to be installed                                                                                                                                                                                             |
| metadata.instance.operating_system.distro                     | Operating system distribution name, like ubuntu                                                                                                                                                                                                |
| metadata.instance.operating_system.os_slug                    | A slug is a combination of operating system distro and version.                                                                                                                                                                                |
| metadata.facility                                            | Facility details                                                                                                                                                                                                                               |
| metadata.facility.facility_code                              | For local setup, `onprem` or any other string value can be used.                                                                                                                                                                               |

For a comprehensive insight into the configurable parameter, the read can inspect the CRD definitions ***[here](https://github.com/tinkerbell/tink/blob/main/config/crd/bases/tinkerbell.org_hardware.yaml)***. 

## The Minimal Hardware Data

While the hardware data is essential, not all the properties are required for every workflow.
In fact, it's upto a workflow designer how they want to use the data in their workflow.
Therefore, you may start with the minimal data given below and only add the properties you would want to use in your workflow.

```yaml

apiVersion: "tinkerbell.org/v1alpha1"
kind: Hardware
metadata:
  name: sm01
  namespace: default
spec:
  disks:
    - device: /dev/nvme0n1
  metadata:
    facility:
      facility_code: onprem
    manufacturer:
      slug: supermicro
    instance:
      userdata: ""
      hostname: "sm01"
      id: "3c:ec:ef:4c:4f:54"
      operating_system:
        distro: "ubuntu"
        os_slug: "ubuntu_20_04"
        version: "20.04"
  interfaces:
    - dhcp:
        arch: x86_64
        hostname: sm01
        ip:
          address: 172.16.10.100
          gateway: 172.16.10.1
          netmask: 255.255.255.0
        lease_time: 86400
        mac: 3c:ec:ef:4c:4f:54
        name_servers:
          - 172.16.10.1
          - 10.1.1.11
        uefi: true
      netboot:
        allowPXE: true
        allowWorkflow: true
```

## Applying Changes to Tinkerbell

Once you are happy with your hardware yaml creations, your next task is to furnish these to a running Tinkerbell system.
This is done via the standard Kubernetes mechanism of applying CRDs. The resources _must_ be deployed to the namespace Tinkerbell services are watching (by default the namespace they're deployed to).
Assuming we previously deployed Tinkerbell in a namespace `tink-system`, and we created a hardware definition in `onpremsm01.yaml`. Then we configure Tinkerbell with this information via:

```
kubectl -n tink-system apply -f onpremsm01.yaml
```
We can inspect what current hardware are under Tinkerbell administration via:

```
kubectl -n tink-system get hardware
```
And we can delete a hardware device from Tinkerbell via either of the below mechanisms - note the second uses the name defined in the `metadata.name` value, and can be retrieved by the prior command above.

```
kubectl -n tink-system delete -f onpremsm01.yaml
or
kubectl -n tink-system delete hardware sm01
```


