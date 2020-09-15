---
title: Local Setup with Vagrant
date: 2020-07-13
---

# Local Setup with Vagrant

If you want to dive in to trying out Tinkerbell, this tutorial sets it up locally using Vagrant. Vagrant manages the Tinkerbell installation for this tutorial's Provisioner, and runs both the Provisioner and Worker on VirtualBox or `libvirtd`.

It covers some basic aspects of Tinkerbell's functionality:

- setting up a Provisioner
- creating the hardware data for the Worker
- creating a template with a placeholder action item, using the [hello-world example](/examples/hello-world-workflow)
- and creating a workflow

The last step is to start up the Worker, which will call back to the Provisioner for its workflow.

## Prerequisites

- [The host's processor should support virtualization](https://www.cyberciti.biz/faq/linux-xen-vmware-kvm-intel-vt-amd-v-support/)
- [Vagrant](https://www.vagrantup.com/downloads) is installed
- Either [VirtualBox](https://www.virtualbox.org/) or [libvirtd](https://libvirt.org/) is installed.

## Getting Tinkerbell

To get Tinkerbell, clone the `tink` repository.

```
git clone https://github.com/tinkerbell/tink.git
```

Move into the `deploy/vagrant` directory. This folder contains a Vagrant configuration file (Vagrantfile) needed to setup the Provisioner and the Worker.

```
cd tink/deploy/vagrant
```

## Start the Provisioner

Since Vagrant is handling the Provisioner's configuration, including installing the Tinkerbell stack, run the command to start it up.

```
vagrant up provisioner
>
Bringing machine 'provisioner' up with 'virtualbox' provider...
```

The Provisioner installs and runs Ubuntu with a couple of additional utilities. The time it takes to spin up the Provisioner varies with connection speed and resources on your local machine.

When the Provisioner is ready, you should see the following message:

```
INFO: tinkerbell stack setup completed successfully on ubuntu server
```

## Starting Tinkerbell

Now that the Provisioner's machine is up and running, you can connect and bring up Tinkerbell. SSH into the Provisioner.

```
vagrant ssh provisioner
>
vagrant@provisioner:~$
```

Tinkerbell is going to be running from a container, so navigate to the `vagrant` directory, set the environment, and start the Tinkerbell stack with `docker-compose`.

```
cd /vagrant && source envrc && cd deploy
docker-compose up -d
```

The Tinkerbell server, and more importantly the CLI, are now managed like a standard Docker Compose project. Just make sure to have sourced the `envrc` before issuing docker-compose commands.

Tinkerbell is now ready to receive templates and workflows. Check out all the Tinkerbell services are running.

```
docker-compose ps
>
        Name                      Command                  State                             Ports
-------------------------------------------------------------------------------------------------------------------------
deploy_boots_1         /boots -dhcp-addr 0.0.0.0: ...   Up
deploy_cacher_1        /cacher                          Up             0.0.0.0:42111->42111/tcp, 0.0.0.0:42112->42112/tcp
deploy_db_1            docker-entrypoint.sh postgres    Up (healthy)   0.0.0.0:5432->5432/tcp
deploy_hegel_1         cmd/hegel                        Up
deploy_nginx_1         /docker-entrypoint.sh ngin ...   Up             192.168.1.2:80->80/tcp
deploy_registry_1      /entrypoint.sh /etc/docker ...   Up (healthy)
deploy_tink-cli_1      /bin/sh -c sleep infinity        Up
deploy_tink-server_1   tink-server                      Up (healthy)   0.0.0.0:42113->42113/tcp, 0.0.0.0:42114->42114/tcp
```

At this point, you might want to open a ssh connection to show logs from the Provisioner, because it will show what the `tink-server` is doing through the rest of the setup. Open a new terminal, ssh in to the provisioner as you did before, and run `docker-compose logs` to tail logs.

```
cd tink/deploy/vagrant
vagrant ssh provisioner
cd /vagrant && source envrc && cd deploy
docker-compose logs -f tink-server boots nginx
```

Later in the tutorial you can check the logs from `tink-server` in order to see the execution of the workflow.

The last step for the Provisioner to do at this point is to pull down the image that will be used in the workflow. Tinkerbell uses Docker registry to host images locally, so pull down the ["Hello World" docker image](https://hub.docker.com/_/hello-world/) and push it to the registry.

```
docker pull hello-world
docker tag hello-world 192.168.1.1/hello-world
docker push 192.168.1.1/hello-world
```

## Creating the Worker's Hardware Data

With the provisioner up and running, it's time to set up the worker's configuration.

First, define the Worker's hardware data, which is used to identify the Worker as the target of a workflow. Very minimal hardware data is required for this example, but it does at least need to contain the MAC Address of the Worker, which is hardcoded in the Vagrant file, and have the Worker set to allow PXE booting and accept workflows.

```
cat > hardware-data.json <<EOF
{
  "id": "ce2e62ed-826f-4485-a39f-a82bb74338e2",
  "metadata": {
    "facility": {
      "facility_code": "onprem"
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
          "mac": "08:00:27:00:00:01",
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
EOF
```

Then, push the hardware data to the database with the `tink hardware push` command.

```
docker exec -i deploy_tink-cli_1 tink hardware push < ./hardware-data.json
> 2020/06/17 14:12:45 Hardware data pushed successfully
```

If you are following along in the `tink-server` logs, you should see:

```
tink-server_1  | {"level":"info","ts":1592936402.3975577,"caller":"grpc-server/hardware.go:37","msg":"data pushed","service":"github.com/tinkerbell/tink","id":"ce2e62ed-826f-4485-a39f-a82bb74338e2"}
```

## Creating a Template

Next, define the template for the workflow. The template sets out tasks for the Worker to preform sequentially. This template contains a single task with a single action, which is to perform "hello-world". Just as in the [hello-world example](/exmaples/hello-world-workflow), the "hello-world" image doesn't contain any instructions that the Worker will perform. It is just a placeholder in the template so a workflow can be created and pushed to the Worker.

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

Create the template and push it to the database with the `tink template create` command.

```
docker exec -i deploy_tink-cli_1 tink template create --name hello-world < ./hello-world.yml
>
Created Template:  75ab8483-6f42-42a9-a80d-a9f6196130df
```

The command returns a Template ID, and if you are watching the `tink-server` logs you will see:

```
tink-server_1  | {"level":"info","ts":1592934670.2717152,"caller":"grpc-server/template.go:34","msg":"done creating a new Template","service":"github.com/tinkerbell/tink"}
```

## Creating the Workflow

The next step is to combine both the hardware data and the template to create a workflow.

- First, the workflow needs to know which template to execute. The Template ID you should use was returned by `tink template create` command executed above.
- Second, the Workflow needs a target, defined by the hardware data. In this example, the target is identified by a MAC address set in the hardware data for our Worker, so `08:00:27:00:00:01`. (Note: this MAC address is hard coded in the Vagrantfile.)

Combine these two pieces of information and create the workflow with the `tink workflow create` command.

```
docker exec -i deploy_tink-cli_1 tink workflow create \
    -t <TEMPLATE ID> \
    -r '{"device_1":"08:00:27:00:00:01"}'
>
Created Workflow:  a8984b09-566d-47ba-b6c5-fbe482d8ad7f
```

The command returns a Workflow ID and if you are watching the logs, you will see:

```
tink-server_1  | {"level":"info","ts":1592936829.6773047,"caller":"grpc-server/workflow.go:63","msg":"done creating a new workflow","service":"github.com/tinkerbell/tink"}
```

## Start the Worker

You can now bring up the Worker and execute the Workflow. In a new terminal window, move into the `tink/deploy/vagrant` directory, and bring up the Worker with Vagrant, similar to bringing up the Provisioner.

```
cd tink/deploy/vagrant
vagrant up worker
```

If you are using VirtualBox, it will bring up a UI, and after the setup, you will see a login screen. You can login with the username `root` and no password is required. Tinkerbell will netboot a custom AlpineOS that runs in RAM, so any changes you make won't be persisted between reboots.

> Note: If you have a high-resolution monitor, here are a few notes about how to make the [UI bigger](https://github.com/tinkerbell/tinkerbell.org/pull/76#discussion_r442151095).

At this point you should check on the Provisioner to confirm that the Workflow was executed on the Worker. If you opened a terminal window to monitor the Tinkerbell logs, you should see the execution in them.

```
tink-server_1  | Received action status: workflow_id:"a8984b09-566d-47ba-b6c5-fbe482d8ad7f" task_name:"hello world" action_name:"hello_world" action_status:ACTION_SUCCESS message:"Finished Execution Successfully" worker_id:"ce2e62ed-826f-4485-a39f-a82bb74338e2"
tink-server_1  | Current context workflow_id:"a8984b09-566d-47ba-b6c5-fbe482d8ad7f" current_worker:"ce2e62ed-826f-4485-a39f-a82bb74338e2" current_task:"hello world" current_action:"hello_world" current_action_state:ACTION_SUCCESS total_number_of_actions:1
```

You can also check using the `tink workflow events` and the Workflow ID on the Provisioner.

```
docker exec -i deploy_tink-cli_1 tink workflow events a8984b09-566d-47ba-b6c5-fbe482d8ad7f
>
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
| WORKER ID                            | TASK NAME   | ACTION NAME | EXECUTION TIME | MESSAGE                         |      ACTION STATUS |
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
| ce2e62ed-826f-4485-a39f-a82bb74338e2 | hello world | hello_world |              0 | Started execution               | ACTION_IN_PROGRESS |
| ce2e62ed-826f-4485-a39f-a82bb74338e2 | hello world | hello_world |              0 | Finished Execution Successfully |     ACTION_SUCCESS |
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
```

## Summary

Getting set up locally is a good way to sample Tinkerbell's functionality. The Vagrant set up is not necessarily intended to be persistent, but while it's up and running, you can use the Provisioner to test out the CLI commands or just explore the stack.


If you are looking to extend your local setup to develop or test out other workflows, check out the [Extending the Vagrant Setup](/setup/extending-vagrant) doc.

That's it! Let us know what you think about it on [Slack](https://slack.packet.com/).
