---
title: Tink Server
date: 2021-02-03
---

# Tink Server

`tink-server` is the primary metadata manager for Tinkerbell, using PostgreSQL for the data store and exposing a gRPC and HTTP API for you to interact with it.

Right now there are three main resources:

* Hardware Data represents a server, router, or generally something you want to provision via Tinkerbell.
* A Template represents what we want to execute.
* A Workflow is a single execution of a template targeting a specific hardware.

By default the gRPC server runs on port `:42113` but you can change it using the
environment variable `TINKERBELL_GRPC_AUTHORITY`.

The HTTP server runs on port `:42114` and you can change it as well using the
environment variable `TINKERBELL_HTTP_AUTHORITY`.

## Building the Binary

`tink-server` uses the standard Golang toolchain. You can clone the `tink` repository:

```
$ git clone git@github.com:tinkerbell/tink
$ go run cmd/tink-server/main.go
$ ./tink-server
```

## Future Development

Currently, we're working on:

* Building better API and client documentation. Right now there is nothing in place.
* We want to version the current API (both gRPC and HTTP) under a `v1` prefix.
* gRPC requires TLS to work but the implementation is not great, there is no concept of identity and the cert is served by the HTTP client. Probably as first step we will remove TLS.
