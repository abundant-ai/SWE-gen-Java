CORS preflight requests can incorrectly fail with HTTP 405 (Method Not Allowed) when the CORS plugin is installed on a specific routing subtree rather than globally. This happens when the incoming request is an OPTIONS preflight for a path that exists (e.g., has a GET handler), but there is no explicit OPTIONS handler at that routing level; instead of being handled by CORS, the request is rejected by routing/method resolution.

Reproduce by installing the `io.ktor.server.plugins.cors.routing.CORS` plugin on a nested `route(...)` and defining a normal handler (e.g., `get("/") { ... }`) under that same route. Then send an OPTIONS request to that path with typical preflight headers such as:

```kotlin
OPTIONS /some/path
Origin: http://my-host
Access-Control-Request-Method: GET
```

Expected behavior: the request should be treated as a CORS preflight and respond successfully (not 405). The response should include appropriate CORS headers (at minimum `Access-Control-Allow-Origin` when the origin is allowed, and the usual preflight allow headers/methods as configured by `CORS`).

Actual behavior: the server responds with `405 Method Not Allowed` because no matching OPTIONS route exists at the point where CORS is installed.

Fix the CORS routing integration so that when `CORS` is installed on a route, it ensures preflight OPTIONS requests under that route are handled (even if the application didn’t declare an explicit OPTIONS handler). In other words, CORS should effectively provide a “tailcard”/catch-all OPTIONS handler at the installation point so preflight requests don’t fail with 405 and instead receive the correct CORS preflight response.