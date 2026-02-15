Static content routes currently return a default static-content response (typically 404/NotFound) when a requested path doesn’t match an existing file/resource. This makes it hard to implement SPA-style routing or custom “missing resource” handling for static directories.

Add support for a configurable fallback handler on static file/resource serving so that when the requested path cannot be resolved to an existing static resource, a user-provided callback can decide what to do.

The static content configuration DSL should accept a new `fallback` block, for example:

```kotlin
staticFiles("/static", File("files")) {
    fallback { requestedPath, call ->
        when {
            requestedPath.endsWith(".php") -> call.respondRedirect("/static/index.html")
            requestedPath.endsWith(".xml") -> call.respond(HttpStatusCode.Gone)
            else -> call.respondFile(File("files/index.html"))
        }
    }
}
```

Behavior requirements:
- `fallback` must be invoked only when the static content lookup fails (i.e., no matching file/resource can be served for the resolved request path). If the resource exists and is served normally, the fallback must not run.
- The fallback callback must receive the path that was requested relative to the static route (as a string, e.g., `nested/missing.txt`), and the current `ApplicationCall` so it can respond.
- If a fallback is configured and the resource is missing, the fallback must be responsible for producing the response (redirect, status code, serving an alternate file, etc.). If no fallback is configured, missing resources should keep the existing behavior.
- Fallback should integrate cleanly with the existing `staticFiles`/`staticResources` DSL and routing, without breaking existing static content features.

The end result should allow applications to implement custom missing-resource behavior (redirects, alternate index file, different status codes) via `fallback { requestedPath, call -> ... }` on static content configuration.