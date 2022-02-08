---
title: Image Registry
date: 2021-03-30
---

Every action Tinkerbell runs as part of a workflow starts from a container image.

We choose this abstraction because a well known concept and it is an agnostic mechanism to package software that describes how it should run.

Container images are also efficient in the way they are built, cached and shipped.

You can use any registry you want:

- It can be a self hosted one like: [distribution] or [Harbor]
- A public one like: Quay or Docker Hub
- A SaaS like GiHub container registry.
- Or even a mix of everything, it is not important

## How and where the registry sits in Tinkerbell stack

The registry needs to be populated from an operator when a new workflow gets registered.
If you create a new template that runs actions depending from a container image that is not available in the registry the workflow will fail.
Because the tink-worker can't run an action if the container image is not available.

Tink-Worker prepends **to all the actions** the internal registry URL you have configured as part of the stack.

If you want to change the registry used by the stack you have to configure `boots`, because it is the glue who passes the information to tink-worker when it boots as part of an in memory operating system.
It requires three variables:

```
DOCKER_REGISTRY: $TINKERBELL_HOST_IP
REGISTRY_USERNAME: $TINKERBELL_REGISTRY_USERNAME
REGISTRY_PASSWORD: $TINKERBELL_REGISTRY_PASSWORD
```

## Things to know about Registry in Sandbox

Sandbox ships [distribution] a registry written by Docker and now part of the Cloud Native Computing Foundation.
Distribution supports many storage like S3, a file system and so on.
Sandbox uses docker-compose and the file system adapter storing images on disks.

[distribution]: https://github.com/distribution/distribution
[harbor]: https://goharbor.io/
