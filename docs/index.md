---
title: Home
date: 2020-07-06
---

# The Tinkerbell Docs

Everything you need to know about Tinkerbell and its major component microservices.
​

## What is Tinkerbell?

Tinkerbell is an open-source, bare metal provisioning engine, built by the team at Equinix Metal.

Interested in contributing? Check out our [Contributors' Page].

## What's Powering Tinkerbell?

The Tinkerbell stack consists of several microservices, and a grpc API:

- [**Tink**] -
  Tink is the short-hand name for the [tink-server], [tink-worker], and [tink-cli].
  `tink-worker` and `tink-server` communicate over gRPC, and are responsible for processing workflows.
  The CLI is the user-interactive piece for creating workflows and their building blocks, templates and hardware data.

- [**Boots**] -
  Boots is Tinkerbell's DHCP server.
  It handles DHCP requests, hands out IPs, and serves up [iPXE].
  It uses the Tinkerbell client to pull and push hardware data.
  It only responds to a predefined set of MAC addresses so it can be deployed in an existing network without interfering with existing DHCP infrastructure.

- [**Hegel**] -
  Hegel is the metadata service used by Tinkerbell and OSIE.
  It collects data from both and transforms it into a JSON format to be consumed as metadata.

- [**OSIE**] -
  OSIE is Tinkerbell's default an in-memory installation environment for bare metal.
  It installs operating systems and handles deprovisioning.

- [**Hook**] -
  An alternative to OSIE, it's the next iteration of the in-memory installation environment to handle operating system installation and deprovisioning.

- [**PBnJ**] -
  PBnJ is an optional microservice that can communicate with baseboard management controllers (BMCs) to control power and boot settings.

In addition to the microservices, there are three pieces of infrastructure:

- [**PostgreSQL**] -
  Tinkerbell uses PostgreSQL as its data store.
  PostgreSQL is a free and open-source relational database management system, and it stores Tinkerbell's hardware data, templates, and workflows.

- [**Image Repository**] -
  Tinkerbell uses a local image repository to store all of the action images used in a workflow.
  This is particularly useful for secure environments that don't have access to the internet.
  You can also choose to use [Quay] or [DockerHub] as the repository to store images for if your environment does have internet access.

- [**NGINX**] - NGINX is a web server which can also be used as a reverse proxy, load balancer, mail proxy, and HTTP cache.
  Tinkerbell uses NGINX to serve the required boot files and OS images during workflow execution.

## First Steps

​New to Tinkerbell or bare metal provisioning? This is a great place to start!

- Getting Started - Set up Tinkerbell [locally with vagrant] or on [Equinix Metal with Terraform].
- Run [hello world] to see Tinkerbell in action.​

## Get Help

Need a little help getting started? We're here!

- Check out the [FAQs] - When there are questions, we document the answers.
- Join the [CNCF Community Slack].
  Look for the [#tinkerbell] channel.
- Submit an issue on [Github].

[**boots**]: /services/boots
[cncf community slack]: https://slack.cncf.org/
[contributors' page]: https://tinkerbell.org/community/contributors/
[dockerhub]: https://hub.docker.com/
[equinix metal with terraform]: /setup/equinix-metal-terraform/
[faqs]: https://tinkerbell.org/faq/
[github]: https://github.com/tinkerbell/
[**hegel**]: /services/hegel
[hello world]: workflows/hello-world-workflow
[ipxe]: https://ipxe.org/
[locally with vagrant]: /setup/local-vagrant/
[**nginx**]: https://www.nginx.com/
[**osie**]: /services/osie
[**pbnj**]: https://github.com/tinkerbell/pbnj
[**postgresql**]: https://www.postgresql.org/
[quay]: https://quay.io/
[tink-cli]: /services/tink-cli
[**tink**]: https://github.com/tinkerbell/tink
[tink-server]: /services/tink-server
[tink-worker]: /services/tink-worker
[#tinkerbell]: https://app.slack.com/client/T08PSQ7BQ/C01SRB41GMT
