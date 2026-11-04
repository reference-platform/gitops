# gitops

Kubernetes manifests for the reference platform, one folder per environment.
ArgoCD reads this repo.

Part of the [reference platform](https://github.com/reference-platform/docs).

## Layout

```
charts/service/        common Helm chart for all services
envs/<env>/
  platform/            owned by the platform team
    root.yaml          root Application, applied once when the cluster is created
    projects.yaml      AppProjects for platform and apps
    appsets.yaml       ApplicationSets for platform and apps
    <name>/            infra components
  apps/<app>/          owned by the dev teams
    <service>/values.yaml   one service, deployed with charts/service
    postgres/               plain manifests for the database of the app
```

Each infra component folder holds two files:

- `config.yaml`: the Helm chart (repo, name, pinned version) and the namespace.
- `values.yaml`: the settings for this environment.

To add a service, add `apps/<app>/<service>/values.yaml`. An ApplicationSet
turns it into an ArgoCD Application named `<env>-<app>-<service>` and renders
`charts/service` with that file. The release name is `<app>-<service>`, so
resources are named `<app>-<service>`. To promote, copy the change to the next
environment's folder. A folder `apps/<app>/postgres/` is deployed as plain
manifests.

Image tags are set by hand in the values files.

Dev-managed apps share the namespace `apps`. With many apps or several teams,
use one namespace per team or org unit, and list it in `projects.yaml`.

The `platform` and `apps` projects separate infra from workloads. See
`.github/CODEOWNERS` for who reviews what.

## CI

On every pull request and push to `main`, GitHub Actions runs `helm lint` and
`helm template` for every service values file, and validates the result and the
plain manifests with [kubeconform](https://github.com/yannh/kubeconform).

All rights reserved. See [LICENSE](LICENSE).
