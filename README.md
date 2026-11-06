# gitops

Kubernetes manifests for the [reference platform](https://github.com/reference-platform/docs).
Argo CD reads this repo and deploys everything in it.

## Layout

```
charts/service/           common Helm chart for all services
platform/<component>/     infra tools: Argo CD, Prometheus, Loki, Alloy
  values.yaml               settings for all clusters
  manifests/                extra plain manifests, if any
  <cluster>/                Application and settings of one cluster
apps/<service>/           one folder per service
  values.yaml               settings for all environments
  <env>/values.yaml         settings of one environment, with the image tag
  manifests/                plain manifests, for a folder without a chart
```

Platform folders are named after the cluster, app folders after the
environment. Both are `dev` today.

## How it works

- Argo CD is installed once by the bootstrap script. After that it deploys
  itself and everything else from this repo.
- `platform/argocd/<cluster>/` holds the root Application, the projects, the
  namespaces and the ApplicationSets. The root Application deploys every
  `platform/<component>/<cluster>/application.yaml`.
- A platform component is one Application: the upstream chart at a pinned
  version, the values from this repo, and the optional `manifests/` folder.
- Each `apps/<service>/<env>/values.yaml` becomes the Application
  `<env>-<service>`, rendered with `charts/service` and deployed to the
  namespace `apps`. A `manifests/` folder is deployed as plain manifests.
- Helm reads the shared `values.yaml` first and the cluster or environment file
  after it. A missing file is skipped.
- Shared files say what a service is: image repository and port. Environment
  files hold the image tag, the resources and the addresses of other systems.
- A service can run a database migration before each sync with the `migration`
  block of the chart. It runs as an Argo CD PreSync hook.
- Applications have no finalizer, and the Argo CD Application does not prune.
  Deleting an Application never removes the workloads.
- Image tags are set by hand.

## CI

On every pull request and push to `main`, GitHub Actions renders each service
with `helm lint` and `helm template`, and validates the result, the plain
manifests and the platform files with
[kubeconform](https://github.com/yannh/kubeconform).

All rights reserved. See [LICENSE](LICENSE).
