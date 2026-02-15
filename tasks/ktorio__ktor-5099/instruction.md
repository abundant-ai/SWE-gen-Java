When building derived clients via `HttpClient.config { ... }`, the `DefaultRequest` plugin configuration can be applied twice due to how client configurations are combined. This causes default request modifiers (such as setting a base URL, headers, or other request defaults) to be duplicated or re-applied unexpectedly.

Reproduction example:
```kotlin
val base = HttpClient(MockEngine) {
    defaultRequest {
        header("X-Test", "base")
    }
}

val derived = base.config {
    defaultRequest {
        header("X-Test", "derived")
    }
}
```
Expected behavior: `derived` should apply the `defaultRequest { ... }` configuration exactly once for each request, with clear override semantics when the derived client configures `defaultRequest` again.

Actual behavior: the derived client may end up combining the base and derived DefaultRequest configurations in a way that results in the DefaultRequest logic being executed twice or defaults being applied more than once.

Add/adjust the `defaultRequest { ... }` configuration API to support an optional `replace` parameter that controls whether the new configuration replaces the previously configured DefaultRequest behavior rather than being merged.

Required behavior:
- `defaultRequest(replace = true) { ... }` must replace the previously configured DefaultRequest settings for the derived client, so that only the new defaults are applied (and applied once).
- `defaultRequest(replace = false) { ... }` (or the default value) should preserve existing merging behavior where appropriate, but must not result in the same DefaultRequest configuration being applied twice when creating a client via `HttpClient.config { ... }`.
- Installing `DefaultRequest` via `install(DefaultRequest) { ... }` should continue to behave consistently with the plugin system, but the duplication bug for `HttpClient.config` + DefaultRequest must be eliminated.

This should work across typical DefaultRequest use cases, including default URL/base path behavior (e.g., setting `url("http://base.url/path/")` and then making requests with relative paths like `get("file")`, root paths like `get("/")`, and absolute/authority URLs like `get("//other.host/other_path")`), ensuring the resolved request URL and defaults are correct and not impacted by double application.