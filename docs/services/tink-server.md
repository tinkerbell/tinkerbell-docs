---
title: Tink Server
---

# Tink Server

Take a look at the code in the [tinkerbell/tink] GitHub repository.

Tink Server exposes workflow actions over a gRPC API for [Tink Worker] to retrieve and execute. When a [Tink Worker] completes an action, it reports the status to Tink Server.
Tink Server uses Kubernetes custom resources to store workflow state.
Tink Server retrieves tasks from and updates task status' on [`Workflow`][workflow] Kubernetes custom resources. Tinkerbell users submit the [`Workflow`][workflow]s to the cluster via the Kube API Server.

[tinkerbell/tink]: https://github.com/tinkerbell/tink/tree/main/cmd/tink-server
[tink worker]: /services/tink-worker
[workflow]: https://github.com/tinkerbell/tink/blob/main/pkg/apis/core/v1alpha1/workflow_types.go
[template]: https://github.com/tinkerbell/tink/blob/main/pkg/apis/core/v1alpha1/template_types.go