---
title: Home
---

# The Tinkerbell Docs

Everything you need to know about Tinkerbell and its major component microservices.

## What is Tinkerbell?

Tinkerbell is an open-source, bare metal provisioning engine, built by the team at Equinix Metal.

Interested in contributing? Check out our [Contributors' Page].

## What's Powering Tinkerbell?

The Tinkerbell stack consists of several microservices, and a grpc API:

- [**Tink**] is the short-hand name for the [tink-server], [tink-worker] and [tink-controller].
  `tink-worker` and `tink-server` communicate over gRPC, and are responsible for processing workflows.
  `tink-controller` is a Kubernetes controller that resolves custom resources representing workflow execution.

- [**Boots**] is Tinkerbell's DHCP server.
  It handles DHCP requests, hands out IPs, and serves up [iPXE].
  It uses the Tinkerbell client to pull and push hardware data.
  It only responds to a predefined set of MAC addresses so it can be deployed in an existing network without interfering with existing DHCP infrastructure.

- [**Hegel**] is the metadata service used by Tinkerbell and Hook.
  It collects data from both and transforms it into a JSON format to be consumed as metadata.

- [**Hook**] is Tinkerbell's default in-memory installation environment for bare metal. Hook executes workflow tasks that result in a provisioned machine.

- [**PBnJ**] is an optional microservice that can communicate with baseboard management controllers (BMCs) to control power and boot settings.

- [**Rufio**] is an optional Kubernetes controller that facilitates baseboard management controller interactions. It operates similarly to PBnJ but has a Kubernetes focused API.

In addition to the microservices, there are three pieces of infrastructure:

- [**Image Repository**] -
  Tinkerbell uses a local image repository to store all of the action images used in a workflow.
  This is particularly useful for secure environments that don't have access to the internet.
  You can also choose to use [Quay] or [Docker Hub] as the repository to store images for if your environment does have internet access.

- [**NGINX**] - NGINX is a web server which can also be used as a reverse proxy, load balancer, mail proxy, and HTTP cache.
  Tinkerbell uses NGINX to serve the required boot files and OS images during workflow execution.

## First Steps

New to Tinkerbell or bare metal provisioning? Visit the [sandbox] for functional examples that illustrate Tinkerbell stack deployment.

## Get Help

Need a little help getting started? We're here!

- Check out the [FAQs] - When there are questions, we document the answers.
- Join the [CNCF Community Slack].
  Look for the [#tinkerbell] channel.
- Submit an issue on [Github].


[**boots**]: /services/boots
[**tink**]: https://github.com/tinkerbell/tink
[**nginx**]: https://www.nginx.com/
[**pbnj**]: https://github.com/tinkerbell/pbnj
[**hook**]: /services/hook
[**image repository**]: https://hub.docker.com/_/registry
[**hegel**]: /services/hegel
[**rufio**]: https://github.com/tinkerbell/rufio

[cncf community slack]: https://slack.cncf.io/
[contributors' page]: https://tinkerbell.org/community/contributors/
[docker hub]: https://hub.docker.com/
[faqs]: https://tinkerbell.org/faq/
[github]: https://github.com/tinkerbell
[ipxe]: https://ipxe.org/
[quay]: https://quay.io/
[tink-cli]: /services/tink-cli
[tink-server]: /services/tink-server
[tink-worker]: /services/tink-worker
[#tinkerbell]: https://app.slack.com/client/T08PSQ7BQ/C01SRB41GMT
[sandbox]: https://github.com/tinkerbell/sandbox