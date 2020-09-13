---
title: Packet Setup with Terraform
date: 2019-01-04
---

# Packet Setup with Terraform

Using Terraform (with the Packet provider), create two servers _tf-provisioner_ and _tf-worker_ attached to the same VLAN.

- Clone the _tink_ repository:

```
git clone https://github.com/tinkerbell/tink.git
cd tink/deploy/terraform
```

- Update the `<packet_api_token>` and `<project_id>` fields in _input.tf_ with your Packet API token and desired project ID
  - Make sure the API token is a user API token (created/accessed under _API keys_ in your personal settings)
  - You may also update the hostnames in _main.tf_ if you prefer names other than _tf-provisioner_ and _tf-worker_
- You may also update the hostnames in _main.tf_ if you prefer names other than _tf-provisioner_ and _tf-worker_
- Run the following commands:

```
terraform init
terraform apply
```

{{% notice note %}}
As an output, it returns the IP address of the provisioner and MAC address of the worker machine.
{{% /notice %}}

## Manual Setup (Optional)

If you do not wish to use Terraform, you can provision the servers manually with the following configurations.

### Provisioner

- Plan: c3.small.x86 (or any plan that supports Layer 2)
- OS: Ubuntu 18.04 LTS
- After device is provisioned:
  - Convert network type to Mixed/Hybrid
  - Attach VLAN to interface eth1 (under Layer 2)

### Worker

- Facility: <same_as_provisioner>
- Plan: c3.small.x86 (or any plan that supports Layer 2)
- OS: Custom iPXE
  - IPXE Script URL: https://boot.netboot.xyz
  - Always/Persist PXE: true
- After device is provisioned:
  - Convert network type to Layer 2 (individual)
  - Attach VLAN to interface eth0
  - Same VLAN as provisioner

## Setting up the Provisioner
SSH into the provisioner for the following steps:

{{% notice note %}}
From here on out, assume all code blocks are run in `bash` unless specified.
{{% /notice %}}

### Run the setup script

The _setup.sh_ script will:

- configure the network
- download necessary files
- setup the certificates
- setup a Docker registry
- start tinkerbell components

The script is also separated into functions so you can rerun specific parts as needed.

```
$ wget https://raw.githubusercontent.com/tinkerbell/tink/master/setup.sh && chmod +x setup.sh
$ ./setup.sh
```

## Action Images

The worker is not open to the world and therefore does not have internet access.
The provisioner and the worker are connected over a private network.
Therefore, it's the responsibility of a user to push all workflow action images to the Docker registry at provisioner.
To push an action image to the registry use:

```
docker tag <action-image> <registry-host>/<action-image>
docker push <registry-host>/<action-image>
```

## Pushing hardware data

- Exec into the tink CLI container using `docker exec -ti deploy_tink-cli_1 /bin/sh`:
- Create a file containing the hardware data (say data.json)
  - ensure that you replace _<worker_mac_addr>_ with the actual worker MAC.
  - the worker MAC can be found in the Terraform output (and also in the generated _terraform.tfstate_ file).
  - if you did not use Terraform to provision the servers, you can call the Packet API _devices_ endpoint, and the worker MAC will be the MAC under _eth0_.

```
https://api.packet.net/devices/{device_id}
...
          "type": "NetworkPort",
          "name": "eth0",
          "data": {
              "bonded": false,
              "mac": "00:00:00:00:00:00" // worker mac
          },
...
```

- Here is the minimal hardware data that can get you started with the [Hello World!](/examples/hello-world-workflow) example.

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
    "state": ""
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

- You can read more about the hardware data under [here](/about/hardware-data).

{{% notice note %}}
You will also have to adjust the `address` and `gateway` under `ip_addresses` accordingly if you chose a non-default subnet and host IP address.
{{% /notice %}}

- Push the hardware data into database with _either_ of the following:

```
$ tink hardware push --file data.json
$ cat data.json | tink hardware push
```

- If the data is valid, you must see a success message.

You can now follow the steps defined in the [Hello World!](/examples/hello-world-workflow) example to test if the setup is ready.
