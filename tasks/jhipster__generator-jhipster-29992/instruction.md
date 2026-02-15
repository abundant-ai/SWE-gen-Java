Running JHipster deployment generators inside a workspace currently causes deployment artifacts (like docker-compose or kubernetes manifests) to be generated in the workspace root. This is incorrect because the workspace root configuration is meant to be owned and consumed by the `workspaces` generator only, and it must not be shared with deployment generators.

When invoking deployment generators (for example the Docker Compose generator via `runJHipsterDeployment(GENERATOR_DOCKER_COMPOSE)` with answers including `directoryPath: '../'` and `appsFolders: [...]`), the generated deployment files should be placed under a dedicated deployment directory (e.g. `docker-compose/`, `kubernetes/`, or `kubernetes-helm/`) inside a deployment folder, rather than being emitted in the workspace root.

Expected behavior: generating deployments for workspace applications produces files under deployment-specific directories such as:
- `docker-compose/docker-compose.yml` and related configuration under `docker-compose/`
- `kubernetes/...` manifests under `kubernetes/`
- `kubernetes-helm/...` charts/manifests under `kubernetes-helm/`

Actual behavior: deployment generation uses the workspace root as the output target and/or reads/propagates workspace root configuration in a way that makes deployment outputs appear at the workspace root or otherwise behave as if workspace config is shared with deployments.

Fix deployment generation so that:
1) Deployment generators do not generate at the workspace root.
2) Workspace root configuration remains isolated to the `workspaces` generator and is not implicitly reused/shared by deployment generators.
3) The deployment generators consistently generate their outputs inside a deployment folder structure, so generating deployments for selected workspace apps results in the expected deployment directory layout (docker-compose/kubernetes/kubernetes-helm) without leaking files to the workspace root.