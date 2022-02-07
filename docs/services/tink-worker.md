---
title: Tink Worker
date: 2021-02-03
---

# Tink Worker

The `tink-worker` is a component provided by the Tinkerbell community, it is written in Go and you can find it as part of the [tink/tinkerbell](https://github.com/tinkerbell/tink) repository.

You can think about it as the "smart" part of an [operating system installation environment](/services/osie).
It is an agent that runs in the operating system that gets booted via netboot, and its responsibility is to interact with the [`tink-server`](/services/tink-server), identifying and executing workflows targeting the hardware it runs to.

The `tink-worker` implementation we ship uses Docker as container runtime engine.
Every action gets executed as a container.

## How `tink-worker` Starts

The way `tink-worker` starts does not follow any particular rule and it is left to the operating system installation environment.
Here an example from [OSIE](https://github.com/tinkerbell/osie).

As part of the [OSIE init](https://github.com/tinkerbell/osie/blob/7dc902956757e0321369ebed10eb66d8e04c8e43/apps/workflow-helper.sh#L68) script the `tink-worker` container gets executed:

```
# tink-worker has been updated to use ID rather than WORKER_ID
# TODO: remove setting WORKER_ID when we no longer want to support backwards compatibility
# with the older tink-worker
docker run --privileged -t --name "tink-worker" \
	-e "container_uuid=$id" \
	-e "WORKER_ID=$worker_id" \
	-e "ID=$worker_id" \
	-e "DOCKER_REGISTRY=$docker_registry" \
	-e "TINKERBELL_GRPC_AUTHORITY=$grpc_authority" \
	-e "TINKERBELL_CERT_URL=$grpc_cert_url" \
	-e "REGISTRY_USERNAME=$registry_username" \
	-e "REGISTRY_PASSWORD=$registry_password" \
	-v /worker:/worker \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-t \
	--net host \
	"$docker_registry/tink-worker:latest"
```

## Future Development

As you can imagine, it would be nice to declare a good interface between `tink-worker` and `tink-server`, simplifying the composition and opening the possibility for you to write your own `tink-worker`.
This is important if you don't want to run Docker, for example.
