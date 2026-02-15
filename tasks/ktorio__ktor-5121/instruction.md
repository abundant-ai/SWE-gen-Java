Ktor server currently doesn’t provide a supported way to respond directly with a classpath resource via an ApplicationCall/response helper, similar to other response convenience functions. Add support for a new API `ApplicationCall.respondResource(...)` (and any required related response functions) that can serve a bundled resource from the application’s classpath.

When an endpoint calls `call.respondResource("testresource.txt", "testdir")`, the server should respond with HTTP 200 and the body equal to the resource contents. The response `Content-Type` must be inferred from the resource file name/extension, for example:
- `call.respondResource("test.html", "testdir")` must respond with `Content-Type: text/html`
- `call.respondResource("test.json", "testdir")` must respond with `Content-Type: application/json`
- `call.respondResource("testresource.txt", "testdir")` must respond with `Content-Type: text/plain`
(Content type comparisons should succeed when parameters like charset are ignored.)

The API must support specifying the package/location of the resource in two equivalent ways:
- `call.respondResource(resource = "testresource.txt", packageName = "testdir")` (positional second argument)
- `call.respondResource(resource = "testresource.txt", resourcePackage = "testdir")` (named argument)
Serving from the root package must also work, e.g. `call.respondResource("logback-test.xml")` should successfully locate and respond with that classpath resource if present.

Error behavior: when the resource cannot be found (either because the file doesn’t exist, or because an incorrect `resourcePackage` is provided), the call should fail the request with `HttpStatusCode.InternalServerError` rather than returning 200 with an empty body.

Implement this so it works in a typical `routing { get("/path") { call.respondResource(...) } }` setup under the JVM server runtime.