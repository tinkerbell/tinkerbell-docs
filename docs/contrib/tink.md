---
title: Contributing to Tink
date: 2021-02-02
---

Tink is the collective term for the codebase that lives in the [tinkerbell/tink] repository, which is a monorepo for the [tink-cli], [tink-server], and [tink-worker].

These 3 sub-projects share the same repo because they have a lot of code in common, mainly coming from the gRPC client and server.
This repository contains the generated gRPC client for Golang as well.

Below we have documented some specific techniques used to develop the components of the Tink repository.

## Running the gRPC API and CLI Locally

You can just spin up just the `tink-cli` and the `tink-server` with their dependencies, and nothing more, directly on a host.
This makes it easier to run debuggers, and minimizes extra layers that are more complicated or a waste of time.

The only external dependency that is needed when working on the `tink-cli` or `tink-server` is PostgreSQL.
It is the database used by `tink-server` to store resources like Workflows, Hardware Data, and Templates.
You can use Docker to manage it for you.

```terminal
docker run -d -e POSTGRES_USER=tinkerbell -e POSTGRES_PASSWORD=tinkerbell -p 5432:5432 postgres:10-alpine
```

In order to apply the database configuration for Tink to the PostgreSQL database, run `tink-server` with the `ONLY_MIGRATION` environment variable set to `true`.

```terminal
export PGPASSWORD=tinkerbell
export FACILITY=onprem
export PGDATABASE=tinkerbell
export PGHOST=127.0.0.1
export PGSSLMODE=disable
export PGUSER=tinkerbell
export TINKERBELL_GRPC_AUTHORITY=:42113
export TINKERBELL_HTTP_AUTHORITY=:42114
export ONLY_MIGRATION=true

go run cmd/tink-server/main.go
```

This will run `tink-server` in migration mode.
If you `unset ONLY_MIGRATION` and you run the `go run` command again it will start the actual gRPC and HTTP server.

At this point, you can develop on the `tink-cli` and run it with `go run`.

```terminal
go run cmd/tink-cli/main.go help
```

[tink-cli]: /services/tink-cli
[tinkerbell/tink]: https://github.com/tinkerbell/tink
[tink-server]: /services/tink-server
[tink-worker]: /services/tink-worker
