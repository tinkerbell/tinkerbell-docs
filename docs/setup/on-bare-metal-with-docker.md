---
title: On Bare Metal with Docker
date: 2021-01-27
---

# On Bare Metal with Docker

More than a documentation, this is an example of installing Tinkerbell in a homelab. The homelab is made of 10 Intel NUCs, with one of them picked to be the Provisioner machine running:

1. Nginx
2. Tink Server
3. Tink CLI
4. PostgreSQL
5. And everything that runs as part of the [docker-compose in sandbox](https://github.com/tinkerbell/sandbox/blob/master/deploy/docker-compose.yml)

This page is inspired by [Aaron](https://geekgonecrazy.com/) a community member who wrote ["Tinkerbell or iPXE boot on OVH"](https://geekgonecrazy.com/2020/09/07/tinkerbell-or-ipxe-boot-on-ovh/).

In this project we will use [Sandbox](https://github.com/tinkerbell/sandbox) and everything it depends on. Pick a server, a laptop, or as in this example, an Intel NUC. 

This guide also provides a little more of an explanation with very little automation for what happens under the hood in guides like:

* [Local Setup with Vagrant](/setup/local-vagrant)
* [Equinix Metal Setup with Terraform](/setup/equinix-metal-terraform)

## Prerequisites

This guide assumes:

- You are familiar with the underline operating system you decided to use.
- You can access the device where you want to install Tinkerbell Provisioner using SSH or Serial console.

## Getting Tinkerbell

To get Tinkerbell, clone the `sandbox` repository.

```
wget https://github.com/tinkerbell/sandbox/archive/v0.4.0.tar.gz
tar xf v0.4.0.tar.gz
cd sandbox-0.4.0
```

In this case we are using the latest sandbox release that today is [v0.4.0](https://github.com/tinkerbell/sandbox/release/v0.4.0). It is important to checkout a specific version and have a look at the changelog when you update. Tinkerbell is under development, but we guarantee as best as we can that tags are good and working end-to-end.

## Generate the Configuration File

The sandbox sets up Tinkerbell using the `setup.sh` script. `setup.sh` relies on a `.env` file that can be generated running the command:

```
./generate-envrc.sh <network-interface> > sandbox/.env
```

In this case, the `network-interface` is `eth1`. The output of this command will be stored inside `./.env`. It will look like this:

```
# Tinkerbell Stack version

export OSIE_DOWNLOAD_LINK=https://tinkerbell-oss.s3.amazonaws.com/osie-uploads/osie-v0-n=366,c=1aec189,b=master.tar.gz
export TINKERBELL_TINK_SERVER_IMAGE=quay.io/tinkerbell/tink:sha-0e8e5733
export TINKERBELL_TINK_CLI_IMAGE=quay.io/tinkerbell/tink-cli:sha-0e8e5733
export TINKERBELL_TINK_BOOTS_IMAGE=quay.io/tinkerbell/boots:sha-e81a291c
export TINKERBELL_TINK_HEGEL_IMAGE=quay.io/tinkerbell/hegel:sha-c17b512f
export TINKERBELL_TINK_WORKER_IMAGE=quay.io/tinkerbell/tink-worker:sha-0e8e5733

# Network interface for Tinkerbell's network
export TINKERBELL_NETWORK_INTERFACE="eth1"

# Decide on a subnet for provisioning. Tinkerbell should "own" this
# network space. Its subnet should be just large enough to be able
# to provision your hardware.
export TINKERBELL_CIDR=29

# Host IP is used by provisioner to expose different services such as
# tink, boots, etc.
#
# The host IP should the first IP in the range, and the Nginx IP
# should be the second address.
export TINKERBELL_HOST_IP=192.168.1.1

# Tink server username and password
export TINKERBELL_TINK_USERNAME=admin
export TINKERBELL_TINK_PASSWORD="1efbd196ae2fa3037c25983b1bc46e4c1230d270d21ed522e83a820192677360"

# Docker Registry's username and password
export TINKERBELL_REGISTRY_USERNAME=admin
export TINKERBELL_REGISTRY_PASSWORD="e32a696ef314bf10a1e17ff94f08ee711cb9a108667f9739e9c0cee0fadb0e76"

# Legacy options, to be deleted:
export FACILITY=onprem
export ROLLBAR_TOKEN=ignored
export ROLLBAR_DISABLE=1
```

The `./.env` file has some explanatory comments, but there are a few things to note about the contents. The environment variables in the `Tinkerbell Stack version` block pin the various parts of the stack to a specific version. You can think of  it as a release bundle.

> If you are developing or you want to test a different version of a particular tool let's say Hegel, you can build and push a docker image, replace `TINKERBELL_TINK_HEGEL_IMAGE` with your tag and you are good to go.

Tinkerbell needs a static and predictable IP, that's why the `setup.sh` script specifies and sets its own with `TINKEBELL_HOST_IP`. It is used by [Boots](https://github.com/tinkerbell/boots) to serve the operating system installation environment, for example. And Sandbox provisions (via Docker Compose) an Nginx server that you can use to serve any file you want (OSIE is served via that Nginx).

## Install Dependencies

The `setup.sh` script does a bunch of manipulation to your local environment, so first we
need to install the required dependencies:

=== "Ubuntu"

    ``` terminal
    sudo apt-get update
    sudo apt-get install -y apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        ifupdown \
        jq \
        software-properties-common \
        git

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    sudo curl -L \
    "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```

=== "CentOS"

    ``` terminal
    sudo yum install -y yum-utils jq ifupdown iproute
    sudo yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo
    yum install docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    ```

## Run the Setup Script

Before running the [setup.sh](https://github.com/tinkerbell/sandbox/blob/master/setup.sh) script, there are a few handy things to know about it.

The `setup.sh` script's main responsibility is to setup the network. It creates a certificate that will be used to setup the registry ([this will may change soon](https://github.com/tinkerbell/sandbox/issues/45)). It downloads [OSIE](https://github.com/tinkerbell/osie) and places it inside the Nginx weboot (`./deploy/state/webroot/`).

> You can use the webroot for your own purposes, it is part of `gitignore` and other than OSIE you can serve other operating systems that you want to install in your other servers, or even public ssh keys (whatever you need a link for).

Now to execute `setup.sh`. 

Load the configuration file:

```
source ./.env
```

and run it:

```
sudo ./setup.sh
```

At the end of the command you have everything you need to start up the Tinkerbell
Provisioner Stack and we use docker-compose for that.

```
cd deploy
docker-compose up -d
```

## Time to Party

At this point let me point you to the ["Local with Vagrant"](/setup/local-vagrant#starting-tinkerbell) setup guide because you have everything you need to play with Tinkerbell. Enjoy
