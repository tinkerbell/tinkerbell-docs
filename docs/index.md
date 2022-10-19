---
title: Home
---

# The Tinkerbell Docs

Everything you need to know about Tinkerbell and its major component microservices.

## What is Tinkerbell?

Tinkerbell is an open-source, bare metal provisioning engine, built by the team at Equinix Metal.

Interested in contributing? Check out our [Contributors' Page].

## What's Powering Tinkerbell?

- **[Tink Server]** is responsible for serving tasks to be run by Tink Worker and updating the state of tasks as reported by Tink worker.

- **[Tink Worker]** is responsible for retrieving and executing workflow tasks. It reports the state of tasks back to Tink Server. It is pre-packaged into our default in-memory provisioning OS, Hook.

- **[Tink Controller]** is responsible for rendering workflow templates and managing workflow state as Tink Worker's report on their task status'. It is an internal component that users generally do not need to interact with.

- **[Boots]** is Tinkerbell's DHCP server.
  It handles DHCP requests, hands out IPs, and serves up [iPXE].
  It uses the Tinkerbell client to pull and push hardware data.
  It only responds to a predefined set of MAC addresses so it can be deployed in an existing network without interfering with existing DHCP infrastructure.

- **[Hook]** is Tinkerbell's default in-memory installation environment for bare metal. Hook executes workflow tasks that result in a provisioned machine.


### Optional services

- **[Hegel]** is a metadata service that can be used during the configuration of a permanent OS.

- **[PBnJ]** is a microservice that can communicate with baseboard management controllers (BMCs) to control power and boot settings.

- **[Rufio]** is a Kubernetes controller that facilitates baseboard management controller interactions. It functions similarly to PBnJ but with a Kubernetes focused API.

## First Steps

New to Tinkerbell or bare metal provisioning? Visit the [sandbox] for functional examples that illustrate Tinkerbell stack deployment.

## Get Help

Need a little help getting started? We're here!

- Check out the [FAQs] - When there are questions, we document the answers.
- Join the [CNCF Community Slack].
  Look for the [#tinkerbell] channel.
- Submit an issue on [Github].


[boots]: /services/boots
[pbnj]: /services/pbnj
[hook]: /hook
[hegel]: /services/hegel
[rufio]: /services/rufio
[tink server]: /services/tink-server
[tink worker]: /services/tink-worker
[tink controller]: /services/tink-controller

[cncf community slack]: https://slack.cncf.io/
[contributors' page]: https://tinkerbell.org/community/contributors/
[docker hub]: https://hub.docker.com/
[faqs]: https://tinkerbell.org/faq/
[github]: https://github.com/tinkerbell
[ipxe]: https://ipxe.org/
[quay]: https://quay.io/
[#tinkerbell]: https://app.slack.com/client/T08PSQ7BQ/C01SRB41GMT
[sandbox]: https://github.com/tinkerbell/sandbox