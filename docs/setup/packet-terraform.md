---
title: Packet Setup with Terraform
date: 2020-09-08
---

# Packet Setup with Terraform

This setup uses the Packet Terraform provider to create two Packet servers, _tf-provisioner_ and _tf-worker_, that are attached to the same VLAN. Then uses the `hello-world` example workflow as an introduction to Tinkerbell. _tf-provisioner_ is will be setup as the Provisioner, running `tink-server`, `boots`, `nginx to serve osie`, `hegel` and Postgres. _tf-worker_ will be setup as the Worker, able to execute workflows.

## Prerequisites

This guide assumes that you already have:

- [A Packet account](https://app.packet.net/login).
- Your Packet API Key and Project ID. The Terraform provider needs to have both to create servers in your account. Make sure the API token is a user API token (created/accessed under _API keys_ in your personal settings).
- [SSH Keys](https://www.packet.com/developers/docs/servers/key-features/ssh-keys/) need to be set up on Packet for the machine where you are running Terraform. Terraform uses your `ssh-agent` to connect to the Provisioner when needed. Double check that the right keys are set.
- [Terraform](https://www.terraform.io/downloads.html) and the [Packet Terraform provider](https://registry.terraform.io/providers/packethost/packet/latest/docs) installed on your local machine.

## Using Terraform

The first thing to do is to clone the `sandbox` repository because it contains the Terraform file required to spin up the environment.

```
git clone https://github.com/tinkerbell/sandbox.git
cd sandbox/deploy/terraform
```

The Packet Terraform module requires a couple of inputs, the mandatory ones are the `packet_api_token` and the `project_id`. You can define them in a `terraform.ftvars` file. By default, Terraform will load the file when present. You can create one `terraform.tfvars` that looks like this:

```
cat terraform.tfvars
packet_api_token = "awegaga4gs4g"
project_id = "235-23452-245-345"
```

Otherwise, you can pass the inputs to the `terraform` command through a file, or in-line with the flag `-var "project_id=235-23452-245-345"`.

Once you have your variables set, run the Terraform commands:

```
terraform init --upgrade
terraform apply
>
Apply complete! Resources: 5 added, 0 changed, 1 destroyed.

Outputs:

provisioner_dns_name = eef33e97.packethost.net
provisioner_ip = 136.144.56.237
worker_mac_addr = [
  "1c:34:da:42:d3:20",
]
worker_sos = [
  "4ac95ae2-6423-4cad-b91b-3d8c2fcf38d9@sos.dc13.packet.net",
]
```

As an output, the `terraform apply` command returns the IP address of the Provisioner, the MAC address of the Worker, and an address for the SOS console of the Worker which will help you to follow what the Worker is doing.

### Troubleshooting - Server Creation

When creating servers on Packet, you might get an error similar to:

```
> Error: The facility sjc1 has no provisionable c3.small.x86 servers matching your criteria.
```

This error notifies you that the facility you are using (by default sjc1) does not have devices available for `c3.small.x86`. You can change your device setting to a different `device_type` in `terraform.tfvars` (be sure that layer2 networking is supported for the new `device_type`), or you can change facility with the variable `facility` set to a different one.

You can check availability of device type in a particular facility through the Packet CLI using the `capacity get` command.

```
packet capacity get
```

You are looking for a facility that has a `normal` level of `c3.small.x84`.

### Troubleshooting - SSH Error

```
> Error: timeout - last error: SSH authentication failed
> (root@136.144.56.237:22): ssh: handshake failed: ssh: unable to authenticate,
> attempted methods [none publickey], no supported methods remain
```

Terraform uses the Terraform [file](https://www.terraform.io/docs/provisioners/file.html) function to copy
the `tink` directory from your local environment to the Provisioner. You can get this error if your local `ssh-agent` properly You should start the agent and add the `private_key` that you use to SSH into the Provisioner.

```
$ ssh-agent
$ ssh-add ~/.ssh/id_rsa
```

Then rerun `terraform apply`. You don't need to run `terraform destroy`, as Terraform can be reapplied over and over, detecting which parts have already been completed.

### Troubleshooting - File Error

```
> Error: Upload failed: scp: /root/tink/deploy: Not a directory
```

Sometimes the `/root/tink` directory is only partially copied onto the the Provisioner. You can SSH onto the Provisioner, remove the partially copied directory, and rerun the Terraform to copy it again.

## Setting Up the Provisioner

SSH into the Provisioner and you will find yourself in a copy of the `tink` repository:

```
ssh -t root@$(terraform output provisioner_ip) "cd /root/tink && bash"
```

You have to define and set Tinkerbell's environment. Use the `generate-envrc.sh` script to generate the `.env` file. Using and setting `.env` creates an idempotent workflow and you can use it to configure the `setup.sh` script. For example changing the [OSIE](/docs/services/osie) version.

```
./generate-envrc.sh enp1s0f1 > .env
source .env
```

Then, you run the `setup.sh` script.

```
./setup.sh
```

`setup.sh` uses the `.env` to install and configure:

- [tink-server](/docs/services/tink)
- [hegel](/docs/services/hegel)
- [boots](/docs/services/boots)
- postgres
- nginx to serve [OSIE](/docs/services/osie)
- A docker registry.

## Running Tinkerbell

The services in Tinkerbell are containerized, and the daemons will run with `docker-compose`. You can find the definitions in `tink/deploy/docker-compose.yaml`. Start all services:

```
cd ./deploy
docker-compose up -d
```

To check if all the services are up and running you can use docker-compose as well. The output should look similar to:

```
docker-compose ps
>
        Name                      Command               State                         Ports
------------------------------------------------------------------------------------------------------------------
deploy_boots_1         /boots -dhcp-addr 0.0.0.0: ...   Up
deploy_db_1            docker-entrypoint.sh postgres    Up      0.0.0.0:5432->5432/tcp
deploy_hegel_1         cmd/hegel                        Up
deploy_nginx_1         /docker-entrypoint.sh ngin ...   Up      192.168.1.2:80->80/tcp
deploy_registry_1      /entrypoint.sh /etc/docker ...   Up
deploy_tink-cli_1      /bin/sh -c sleep infinity        Up
deploy_tink-server_1   tink-server                      Up      0.0.0.0:42113->42113/tcp, 0.0.0.0:42114->42114/tcp
```

You now have a Provisioner up and running on Packet. The next steps take you through creating a workflow and pushing it to the Worker using the `hello-world` workflow example. If you want to use the example, you need to pull the `hello-world` image from from Docker Hub to the internal registry.

```
docker pull hello-world
docker tag hello-world 192.168.1.1/hello-world
docker push 192.168.1.1/hello-world
```

## Registering the Worker

As part of the `terraform apply` output you get the MAC address for the worker and it generates a file that contains the JSON describing it. Now time to register it with Tinkerbell.

```
cat /root/tink/deploy/hardware-data-0.json
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
          "mac": "1c:34:da:5c:36:88",
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

{{% notice note %}}
The mac address is the same we get from the Terraform output
{{% /notice %}}

Now we can push the hardware data to `tink-server`:

```
docker exec -i deploy_tink-cli_1 tink hardware push < /root/tink/deploy/hardware-data-0.json
>
2020/06/17 14:12:45 Hardware data pushed successfully
```

A note on the Worker at this point. Ideally the worker should be kept from booting until the Provisioner is ready to serve it OSIE, but on Packet that probably doesn't happen. Now that the Worker's hardware data is registered with Tinkerbell, you should manually reboot the worker through the Packet [CLI](https://github.com/packethost/packet-cli/blob/master/docs/packet_device_reboot.md), [API](https://www.packet.com/developers/api/devices/#devices-performAction), or Packet UI. Remember to use the SOS console to check what the Worker is doing.

## Creating a Template

Next, define the template for the workflow. The template sets out tasks for the Worker to preform sequentially. This template contains a single task with a single action, which is to perform [“hello-world”](/docs/examples/hello-world). Just as in the hello-world example, the `hello-world` image doesn’t contain any instructions that the Worker will perform. It is just a placeholder in the template so a workflow can be created and pushed to the Worker.

```
cat > hello-world.yml  <<EOF
version: "0.1"
name: hello_world_workflow
global_timeout: 600
tasks:
  - name: "hello world"
    worker: "{{.device_1}}"
    actions:
      - name: "hello_world"
        image: hello-world
        timeout: 60
EOF
```

Create the template and push it to the `tink-server` with the `tink template create` command.

```
$ docker exec -i deploy_tink-cli_1 tink template create --name hello-world < ./hello-world.yml

Created Template:  75ab8483-6f42-42a9-a80d-a9f6196130df
```

{{% notice note %}}
TIP: export the the template ID as a bash variable for future use.
{{% /notice %}}

```
$ export TEMPLATE_ID=75ab8483-6f42-42a9-a80d-a9f6196130df
```

## Creating a Workflow

The next step is to combine both the hardware data and the template to create a workflow.

- First, the workflow needs to know which template to execute. The Template ID you should use was returned by `tink template create` command executed above.
- Second, the Workflow needs a target, defined by the hardware data. In this example, the target is identified by the MAC address you got back from the `terraform apply` command

Combine these two pieces of information and create the workflow with the `tink workflow create` command.

```
$ docker exec -i deploy_tink-cli_1 tink workflow create \
    -t $TEMPLATE_ID \
    -r '{"device_1":'$(jq .network.interfaces[0].dhcp.mac hardware-data-0.json)'}'

Created Workflow:  a8984b09-566d-47ba-b6c5-fbe482d8ad7f
```

{{% notice note %}}
TIP: export the the workflow ID as a bash variable.
{{% /notice %}}

```
$ export WORKFLOW_ID=a8984b09-566d-47ba-b6c5-fbe482d8ad7f
```

The command returns a Workflow ID and if you are watching the logs, you will see:

```
tink-server_1  | {"level":"info","ts":1592936829.6773047,"caller":"grpc-server/workflow.go:63","msg":"done creating a new workflow","service":"github.com/tinkerbell/tink"}
```

## Checking Workflow Status

You can not SSH directly into the Worker but you can use the `SOS` or `Out of bond` console provided by Packet to follow what happens in the Worker during the workflow. You can SSH into the SOS console with:

```
ssh $(terraform output -json worker_sos | jq -r '.[0]')
```

You can also use the CLI from the provisioner to validate if the workflow completed correctly using the `tink workflow events` command.

{{% notice note %}}
Note that an event can take ~5 minutes to show up.
{{% /notice %}}

```
docker exec -i deploy_tink-cli_1 tink workflow events $WORKFLOW_ID
>
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
| WORKER ID                            | TASK NAME   | ACTION NAME | EXECUTION TIME | MESSAGE                         |      ACTION STATUS |
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
| ce2e62ed-826f-4485-a39f-a82bb74338e2 | hello world | hello_world |              0 | Started execution               | ACTION_IN_PROGRESS |
| ce2e62ed-826f-4485-a39f-a82bb74338e2 | hello world | hello_world |              0 | Finished Execution Successfully |     ACTION_SUCCESS |
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
```

## Cleanup

You can terminate worker and provisioner with the `terraform destroy` command:

```
terraform destroy
```
