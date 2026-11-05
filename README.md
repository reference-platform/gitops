# gitops

Kubernetes manifests for the [reference platform](https://github.com/reference-platform/docs).

## Layout

```
charts/service/        common Helm chart for all services
envs/<env>/
  platform/            owned by the platform team
    root.yaml          root Application, applied once at bootstrap, then manages itself
    projects.yaml      AppProjects for platform and apps
    namespaces.yaml    namespaces for the apps, created by the platform team
    appsets.yaml       ApplicationSets for platform and apps
    <name>/            infra components
  apps/<app>/          owned by the dev teams
    <service>/values.yaml   one service, deployed with charts/service
    manifests/              plain manifests of the app, without a chart
```

Each infra component folder holds two files:

- `config.yaml`: the Helm chart (repo, name, pinned version) and the namespace.
- `values.yaml`: the settings for this environment.

The release name is the folder name. ArgoCD itself is one of these components
(`argocd/`). The bootstrap script installs it once from these two files, then
ArgoCD updates itself from Git. The Application has no finalizer, so deleting
it never removes ArgoCD. The root Application and the `apps` namespace are
marked so that ArgoCD never prunes or deletes them.

Each `apps/<app>/<service>/values.yaml` becomes an ArgoCD Application named
`<env>-<app>-<service>`, rendered with `charts/service`. The release name is
`<app>-<service>`, so resources use that name. A folder `apps/<app>/manifests/`
is deployed as plain manifests. These are not pruned: deleting a file leaves
its resource in the cluster until someone removes it by hand.

Image tags are set by hand in the values files.

Dev-managed apps share the namespace `apps`. The platform team creates it in
`namespaces.yaml`, because the `apps` project cannot create cluster-wide
resources.

The `platform` and `apps` projects separate infra from workloads. See
`.github/CODEOWNERS` for who reviews what.

## CI

On every pull request and push to `main`, GitHub Actions runs `helm lint` and
`helm template` for every service values file, and validates the result and the
plain manifests with [kubeconform](https://github.com/yannh/kubeconform). It
also validates the platform files (Applications, projects, ApplicationSets)
against the ArgoCD CRD schemas.

All rights reserved. See [LICENSE](LICENSE).
