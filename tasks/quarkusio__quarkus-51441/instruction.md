Quarkus’ Kubernetes extension still accepts a deprecated “old-style” environment variable declaration format in configuration. This compatibility layer is being removed, but current behavior is inconsistent: some old-style keys may still be accepted silently, may conflict with the newer mapping-based configuration, or may lead to unclear/late failures when generating Kubernetes manifests.

The Kubernetes extension should only accept the current env-var declaration style and should reject deprecated env-var declaration keys with a clear error. At the same time, env-var declarations coming from the supported configuration and from build items must be validated for conflicts and redundancies before resources are generated.

In particular, implement and/or adjust the validation logic around `EnvVarValidator` and `KubernetesEnvBuildItem` so that:

- When multiple `KubernetesEnvBuildItem`s are processed for the same target (for example, "kubernetes"), `EnvVarValidator.getBuildItems()` returns a collection with:
  - No items when none were processed.
  - Exactly one item when one was processed.
  - Exactly one item when duplicate/redundant items of the same “kind” and same env-var name are processed (e.g., two identical "from configmap" declarations for the same name).
- If two incompatible env-var declarations share the same env-var name (e.g., one is a simple literal value and another is a "from field" reference), calling `EnvVarValidator.getBuildItems()` must fail with an exception whose message contains the env-var name and the conflicting values involved (so users can see exactly what is conflicting).
- Multiple env-var declarations with the same env-var name must be allowed only when they are compatible (for example, a simple literal env var plus additional `envFrom`-style declarations such as from secret/configmap when those do not redefine the same env-var key). Compatible combinations must not throw.

Separately, configuration parsing must no longer accept deprecated env-var declaration keys (the removed old-style format). When a user provides deprecated keys for env var configuration under Kubernetes/Minikube/OpenShift configuration prefixes, the build should fail early with a clear message indicating that the env-var declaration style is deprecated/unsupported and that the user must migrate to the supported configuration format.

Example scenarios that must work:

- Defining env vars via the supported configuration format for simple vars (e.g., `...env.vars.<name>=<value>`), from fields (e.g., `...env.fields.<name>=metadata.name`), and via configmaps/secrets mapping must result in generated manifests containing the expected environment settings.
- Providing both `createSimpleVar("name","foo",target)` and `createFromField("name","bar",target)` must fail on `getBuildItems()` and the error message must include: `name`, `foo`, and `bar`.
- Providing two identical `createFromConfigMap("name", target, null)` entries must not fail and must produce only one resulting build item.

The goal is that deprecated env var declaration styles are fully removed (no silent acceptance), while the remaining supported paths produce deterministic results and clear failures on conflict.