---
title: Hegel
date: 2020-08-31
---

# Hegel

Hegel is Tinkerbell's metadata store, supporting storage and retrieval of metadata over gRPC and HTTP.
It also provides a compatible layer with the AWS EC2 metadata format.

Metadata is user-defined as part of the hardware data that makes up a workflow.

Take a look at the code in the [tinkerbell/hegel] GitHub repository.

## Using Hegel

You can access Hegel in a Tinkerbell setup at the Provisioner's IP address `/metadata`.
You can use cURL to retrieve the metadata it stores.

Hegel by default exposes an `HTTP` API on port `50061`.
You can interact with it via cURL

```sh
curl $HEGEL_IP:50061/metadata
```

You can also retrieve a AWS EC2 compatible format uses from `/meta-data`.

```sh
curl $HEGEL_IP:50061/<date>/meta-data
```

For example, if you are using the Local Setup with Vagrant, Hegel runs as part of the Provisioner virtual machine with the IP: `192.168.1.1`.
When the Worker starts and if you have logged in to [hook] using the password `root` you can access the metadata for your server via `curl`:

```sh
curl -s "192.168.1.1:50061/metadata" | jq .
{
  "facility": {
    "facility_code": "onprem"
  },
  "instance": {},
  "state": ""
}
```

Or in AWS EC2 format:

```sh
curl -s "192.168.1.1:50061/2009-04-04/meta-data"
```

If you look at the `hardware-data.json` that we used during the Vagrant setup you will find the `facility_code=onprem` as well.

## Other Resources

Every cloud provider is capable of exposing metadata to servers that you can query as part of your automation, usually via HTTP.
Some examples are:

- [AWS: Instance metadata and user data]
- [GCP: Storing and retrieving instance metadata]
- [Equinix Metal: Metadata]

[aws: instance metadata and user data]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
[equinix metal: metadata]: https://metal.equinix.com/developers/docs/servers/metadata/
[gcp: storing and retrieving instance metadata]: https://cloud.google.com/compute/docs/metadata/overview
[hook]: /services/osie
[tinkerbell/hegel]: https://github.com/tinkerbell/hegel
