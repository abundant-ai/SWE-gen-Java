When a controller expects a JSON request body (e.g., `@Post @Consumes(APPLICATION_JSON)` with `@Body Request request`) and the incoming JSON is malformed such that body binding fails (commonly resulting in a `ConversionErrorException`), a global `@Error` handler should still be able to access the original request body.

Currently on Micronaut 4.x, if JSON decoding/binding fails during normal route execution, the request body is effectively consumed/claimed in a way that prevents subsequent access in an error controller. In a global error handler like:

```java
@Error(global = true)
public HttpResponse<String> genericException(HttpRequest<?> request, Exception e) {
    Optional<String> body = request.getBody(String.class);
    // or: accept a parameter like @Body String rawBody
}
```

`request.getBody(String.class)` (and/or binding `@Body String rawBody` in the error route) unexpectedly yields an empty `Optional` / no body, even though the client sent a body.

Expected behavior: If body conversion fails (e.g., due to JSON syntax error), the raw request bytes should remain available for a fallback conversion in the error handler so that the handler can obtain the original payload as a `String` (or another type), matching behavior seen in Micronaut 3.9.x.

Actual behavior: After the initial conversion failure, the underlying request body state is left advanced/claimed such that fallback body retrieval in the `@Error(global=true)` handler does not work.

Reproduction scenario:
1) Define a controller method that consumes JSON and binds it to a POJO via `@Body`.
2) Send a request with a malformed JSON payload.
3) Handle the resulting exception via a global `@Error` method.
4) Attempt to read the body in the error handler using `request.getBody(String.class)` and/or by binding `@Body String` as an argument.

The fix should ensure that when single-shot body processing/conversion fails, the request body buffer/position is not left in a consumed state, so a subsequent attempt to bind/read the body in the error handler can succeed and retrieve the raw body content.