---
title: Tink Server
date: 2020-08-31
---

# Tink Server

The tink-server uses Postgres as data store and it exposes a gRPC and HTTP API where all the metadata are stored.

Right now there are three main resources:

* Hardware represents a server, or router, more in general something to provision via Tinkerbell
* Template represents what we want to execute
* Workflow is a single execution of a template targeting a specific hardware

By default the gRPC server runs on port `:42113` but you can change it using the
environment variable `TINKERBELL_GRPC_AUTHORITY`.

The HTTP server runs on port `:42114` and you can change it as well via the
environment variable `TINKERBELL_HTTP_AUTHORITY`.

### Building the Binary

Tink Server uses the standard Golang toolchain. You can clone the tink repository:

```
$ git clone git@github.com:tinkerbell/tink
$ go run cmd/tink-server/main.go
$ ./tink-server
```

## Next steps

* We have to do a better job around API and client documentation. Right now there is nothing in place
* We want to version the current API (both gRPC and HTTP) under a `v1` prefix
* gRPC requires TLS to work but the implementation is not great, there is no concept of identity and the cert is served by the HTTP client. Probably as first step we will remove TLS.
