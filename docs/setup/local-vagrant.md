---
title: Local Setup with Vagrant
date: 2021-11-30
---

# Local Setup with Vagrant

If you want to dive in to trying out Tinkerbell, this tutorial sets it up locally using Vagrant.
Vagrant manages the Tinkerbell installation for this tutorial's Provisioner, and runs both the Provisioner and Worker on VirtualBox or `libvirtd`.

These docs were tested against v0.6.0 of github.com/tinkerbell/sandbox

It covers some basic aspects of Tinkerbell's functionality:

- setting up a Provisioner
- creating the hardware data for the Worker
- creating a template with a placeholder action item, using the [hello world] template
- and creating a workflow

The last step is to start up the Worker, which will call back to the Provisioner for its workflow.

## Prerequisites

- [The host's processor should support virtualization]
- [Vagrant] is installed
- Either [VirtualBox] or [libvirtd] is installed.
- If using VirtualBox be sure to install both:
  - The Vagrant _vagrant-vbguest_ plugin: `vagrant plugin install vagrant-vbguest`
  - The [VirtualBox Extension Pack]
- If using VirtualBox, you may get an error about valid IP addresses for host-only networks. [This page from the Virtual Box manual explains how to add additional address ranges to your setup.]

## Getting Tinkerbell

To get Tinkerbell, clone the `sandbox` repository at version v0.6.0.

```
git clone https://github.com/tinkerbell/sandbox.git -b v0.6.0
```

Move into the `deploy/vagrant` directory.
This folder contains a Vagrant configuration file (Vagrantfile) needed to setup the Provisioner and the Worker.

```
cd sandbox/deploy/vagrant
```

## Start the Provisioner

First we need to delete the default template and hardware definition that the sandbox repo comes with.
This lets us practice setting up the template and workflow in tinkerbell without any conflicts with what comes pre-defined in the sandbox repo.

```
rm ../compose/manifests/hardware/hardware-libvirt.json
rm ../compose/manifests/hardware/hardware.json
rm ../compose/manifests/template/ubuntu-libvirt.yaml
rm ../compose/manifests/template/ubuntu.yaml
```

Since Vagrant is handling the Provisioner's configuration, including installing the Tinkerbell stack, run the command to start it up.

```
vagrant up provisioner
```

The Provisioner installs and runs Ubuntu with a couple of additional utilities.
The time it takes to spin up the Provisioner varies with connection speed and resources on your local machine.

## Inspecting the running Tinkerbell containers

Now that the Provisioner's machine is up and running, SSH into the Provisioner.

```
vagrant ssh provisioner
```

Tinkerbell is going to be running from a container, so navigate to the `/vagrant/compose` directory and load up the .env file that has all our environment's settings in it, and start the Tinkerbell stack with `docker-compose`.

```
cd /vagrant/compose
docker-compose ps
```

```
               Name                             Command                  State                             Ports
---------------------------------------------------------------------------------------------------------------------------------------
compose_boots_1                      /usr/bin/boots -dhcp-addr  ...   Up
compose_create-tink-records_1        /manifests/exec_in_bash.sh ...   Exit 0
compose_db_1                         docker-entrypoint.sh postgres    Up (healthy)   0.0.0.0:5432->5432/tcp
compose_hegel_1                      /usr/bin/hegel                   Up             0.0.0.0:50060->50060/tcp, 0.0.0.0:50061->50061/tcp
compose_images-to-local-registry_1   /registry/upload.sh admin  ...   Exit 1
compose_osie-bootloader_1            /docker-entrypoint.sh ngin ...   Up             0.0.0.0:8080->80/tcp
compose_osie-work_1                  /scripts/lastmile.sh https ...   Exit 0
compose_registry-auth_1              htpasswd -Bbc .htpasswd ad ...   Exit 0
compose_registry-ca-crt-download_1   wget http://192.168.50.4:4 ...   Exit 0
compose_registry_1                   /entrypoint.sh /etc/docker ...   Up (healthy)
compose_tink-cli_1                   /bin/sh -c sleep infinity        Up
compose_tink-server-migration_1      /usr/bin/tink-server             Exit 0
compose_tink-server_1                /usr/bin/tink-server             Up (healthy)   0.0.0.0:42113->42113/tcp, 0.0.0.0:42114->42114/tcp
compose_tls-gen_1                    /code/tls/generate.sh 192. ...   Exit 0
compose_ubuntu-image-setup_1         /scripts/setup_ubuntu.sh h ...   Exit 0

```

## Preparing an action image

As you'll see shortly, each step in a Tinkerbell workflow is referred to as an Action Image, and is simply a Docker image.
Before you move ahead, let's pull down the image that will be used in the example workflow.
Tinkerbell uses Docker registry to host images locally, so pull down the [Hello World Docker image] and push it to the registry.

Let's trust the SSL certs of the registry container.

```
cd /vagrant/compose && source .env
echo | openssl s_client -showcerts -connect $TINKERBELL_HOST_IP:443 2>/dev/null | openssl x509 | sudo tee /usr/local/share/ca-certificates/tinkerbell.crt
sudo update-ca-certificates
sudo systemctl restart docker
```

Then let's login, get the image, and upload it to our registry.

```
docker login $TINKERBELL_HOST_IP -u admin -p Admin1234
docker pull hello-world
docker tag hello-world $TINKERBELL_HOST_IP/hello-world
docker push $TINKERBELL_HOST_IP/hello-world
```

At this point, you might want to open a separate terminal window to show logs from the Provisioner, because it will show what the `tink-server` is doing through the rest of the setup.
Open a new terminal, ssh in to the provisioner as you did before, and run `docker-compose logs -f` to tail logs.

```
cd sandbox/deploy/vagrant
vagrant ssh provisioner
cd /vagrant/compose && source .env
docker-compose logs -f tink-server boots osie-bootloader
```

Later in the tutorial you can check the logs from `tink-server` in order to see the execution of the workflow.

## Creating the Worker's Hardware Data

With the provisioner up and running, it's time to set up the worker's configuration.

First, define the Worker's hardware data, which is used to identify the Worker as the target of a workflow.
Very minimal hardware data is required for this example, but it does at least need to contain the MAC Address of the Worker, which is hardcoded in the Vagrant file, and have the Worker set to allow PXE booting and accept workflows.

```
cat > hardware-data.json <<EOF
{
  "id": "7462cca3-5539-4524-90e9-ab98c3fabf27",
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
            "address": "192.168.50.44",
            "gateway": "192.168.50.1",
            "netmask": "255.255.255.0"
          },
          "mac": "08:00:27:9E:F5:3A",
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
docker exec -i compose_tink-cli_1 tink hardware push < ./hardware-data.json
```

If you are following along in the `tink-server` logs, you should see:

```
tink-server_1               | {"level":"info","ts":1638306331.943881,"caller":"grpc-server/hardware.go:82","msg":"data pushed","service":"github.com/tinkerbell/tink","id":"7462cca3-5539-4524-90e9-ab98c3fabf27"}
```

## Creating a Template

Next, define the template for the workflow.
The template sets out tasks for the Worker to preform sequentially.
This template contains a single task with a single action, which is to perform "hello-world".
Just as in the [hello-world example], the "hello-world" image doesn't contain any instructions that the Worker will perform.
It is just a placeholder in the template so a workflow can be created and pushed to the Worker.

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
docker exec -i compose_tink-cli_1 tink template create  < ./hello-world.yml
```

The command returns a Template ID, and if you are watching the `tink-server` logs you will see:

```
tink-server_1               | {"level":"info","ts":1638306365.5689096,"caller":"grpc-server/template.go:42","msg":"done creating a new Template","service":"github.com/tinkerbell/tink"}
```

## Creating the Workflow

The next step is to combine both the hardware data and the template to create a workflow.

- First, the workflow needs to know which template to execute.
  The Template ID you should use was returned by `tink template create` command executed above.
- Second, the Workflow needs a target, defined by the hardware data.
  In this example, the target is identified by a MAC address set in the hardware data for our Worker, so `08:00:27:00:00:01`.
  !!!!!!! (Note: this MAC address is the one we hard coded in the Vagrantfile earlier.)

Combine these two pieces of information and create the workflow with the `tink workflow create` command.

```
docker exec -i compose_tink-cli_1 tink workflow create -r '{"device_1":"08:00:27:9E:F5:3A"}' -t <TEMPLATE ID>
```

The command returns a Workflow ID and if you are watching the logs, you will see:

```
tink-server_1               | {"level":"info","ts":1638306500.9581006,"caller":"grpc-server/workflow.go:70","msg":"done creating a new workflow","service":"github.com/tinkerbell/tink","workflowID":"a5ba16e0-5221-11ec-89e8-0242ac120005"}
```

## Start the Worker

You can now bring up the Worker and execute the Workflow.
In a new terminal window, move into the `tink/deploy/vagrant` directory, and bring up the Worker with Vagrant, similar to bringing up the Provisioner.

```
cd sandbox/deploy/vagrant
vagrant up machine1
```

If you are using VirtualBox, it will bring up a UI, and after the setup, you will see a login screen.
You can login with the username `root` and no password is required.
Tinkerbell will netboot a custom AlpineOS that runs in RAM, so any changes you make won't be persisted between reboots.

> Note: If you have a high-resolution monitor, here are a few notes about how to make the [UI bigger].

At this point you should check on the Provisioner to confirm that the Workflow was executed on the Worker.
If you opened a terminal window to monitor the Tinkerbell logs, you should see the execution in them.

```
tink-server_1               | {"level":"info","ts":1638388091.1408234,"caller":"grpc-server/tinkerbell.go:97","msg":"received action status: STATE_SUCCESS","service":"github.com/tinkerbell/tink","actionName":"hello_world","workflowID":"6e40f68f-52df-11ec-974f-0242ac120006"}
tink-server_1               | {"level":"info","ts":1638388091.1498456,"caller":"grpc-server/tinkerbell.go:147","msg":"current workflow context","service":"github.com/tinkerbell/tink","workflowID":"6e40f68f-52df-11ec-974f-0242ac120006","currentWorker":"7462cca3-5539-4524-90e9-ab98c3fabf27","currentTask":"hello world","currentAction":"hello_world","currentActionIndex":"0","currentActionState":"STATE_SUCCESS","totalNumberOfActions":1}
```

You can also check using the `tink workflow events` and the Workflow ID on the Provisioner.

```
docker exec -i compose_tink-cli_1 tink workflow events a8984b09-566d-47ba-b6c5-fbe482d8ad7f
>
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
| WORKER ID                            | TASK NAME   | ACTION NAME | EXECUTION TIME | MESSAGE                         |      ACTION STATUS |
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
| 7462cca3-5539-4524-90e9-ab98c3fabf27 | hello world | hello_world |              0 | Started execution               | ACTION_IN_PROGRESS |
| 7462cca3-5539-4524-90e9-ab98c3fabf27 | hello world | hello_world |              0 | Finished Execution Successfully |     ACTION_SUCCESS |
+--------------------------------------+-------------+-------------+----------------+---------------------------------+--------------------+
```

## Summary

Getting set up locally is a good way to sample Tinkerbell's functionality.
The Vagrant set up is not necessarily intended to be persistent, but while it's up and running, you can use the Provisioner to test out the CLI commands or just explore the stack.

If you are looking to extend your local setup to develop or test out other workflows, check out the [Extending the Vagrant Setup] doc.

That's it!
Let us know what you think about it in the #tinkerbell channel on the [CNCF Community Slack].

[cncf community slack]: https://slack.cncf.io/
[extending the vagrant setup]: /setup/extending-vagrant
[hello world docker image]: https://hub.docker.com/_/hello-world/
[hello world]: /workflows/hello-world-workflow
[libvirtd]: https://libvirt.org/
[the host's processor should support virtualization]: https://www.cyberciti.biz/faq/linux-xen-vmware-kvm-intel-vt-amd-v-support/
[this page from the virtual box manual explains how to add additional address ranges to your setup.]: https://www.virtualbox.org/manual/ch06.html#network_hostonly
[ui bigger]: https://github.com/tinkerbell/tinkerbell.org/pull/76#discussion_r442151095
[vagrant]: https://www.vagrantup.com/downloads
[virtualbox extension pack]: https://www.virtualbox.org/wiki/Downloads
[virtualbox]: https://www.virtualbox.org/
