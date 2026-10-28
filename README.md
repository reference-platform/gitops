# gitops

Kubernetes manifests for the reference platform, one folder per environment.
ArgoCD reads this repo.

Part of the [reference platform](https://github.com/reference-platform/docs).

## Layout

```
envs/<env>/
  platform/            owned by the platform team
    root.yaml          root Application, applied once when the cluster is created
    projects.yaml      AppProjects for platform and apps
    appsets.yaml       ApplicationSets for platform and apps
    <name>/            infra components
  apps/<name>/         workloads, owned by the dev teams
```

Each component folder holds two files:

- `config.yaml`: the Helm chart (repo, name, pinned version) and the namespace.
- `values.yaml`: the settings for this environment.

To add a component, add a folder with these two files. An ApplicationSet turns
it into an ArgoCD Application named `<env>-<name>`. To promote, change the
chart version or the image tag in the next environment's folder.

Dev-managed apps share the namespace `apps`. With many apps or several teams,
use one namespace per team or org unit, and list it in `projects.yaml`.

The `platform` and `apps` projects separate infra from workloads. See
`.github/CODEOWNERS` for who reviews what.

All rights reserved. See [LICENSE](LICENSE).
