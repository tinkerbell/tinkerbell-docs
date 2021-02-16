---
title: Contribute to Tink
date: 2021-02-02
---

When we refer to Tink we are speaking about the content of [tinkerbell/tink](https://github.com/tinkerbell/tink) repository.

You can see it as a monorepo for [tink-cli](/services/tink-cli), [tink-server](/services/tink-server), and [tink-worker](/services/tink-worker).

Those 3 sub projects shares the same repo because they have a lot of code in common (mainly coming from the gRPC Client and Server) and it is time consuming to have them in their own repository at the moment. This repository contains the generated gRPC client for Golang as well. I am sure moving forward some of those projects will live in their own repository but for now they are all sharing the same repository.

At the time I am writing this article I am not sure about the layout or the evolution for the Contribute guide. I will just create my `H1` title that will explain a personal or specific techniques I use to develop something in the Tink repository.

## Running the gRPC API and CLI locally

I am a developer who likes to spin up all the dependencies that I need for the code I have to develop, nothing more. I don't the point of spinning up the entire Stack if I have to call a gRPC API t hat talks to a database. When it comes to the actual code I am working at I like to build it directly on the host because it is easier to run debuggers in there and there are not layers that can make my journey more complicated or a waste of time. I don't want to debug intermediate level when I can avoid.

The only external dependencies that I usually have to solve when working at the tink-cli or tink-server level is Postgres. It is the database used by the Tink Server to store resources like Workflows, Hardware and Template. I use Docker for that:

```terminal
docker run -d -e POSTGRES_USER=tinkerbell -e POSTGRES_PASSWORD=tinkerbell -p 5432:5432 postgres:10-alpine
```

In order to apply the database migration to that Postgres database we have to run the tink-server with the `ONLY_MIGRATION` env var set to `true`.

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

This will run the tink-server in migration-mode. If you `unset ONLY_MIGRATION`
and you run the `go run` command again it will start the actual gRPC and HTTP
server.

At this point you can do what you want, you can develop the tink-cli and run it
with `go run`

```terminal
go run cmd/tink-cli/main.go help
```
