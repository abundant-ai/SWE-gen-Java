Retrofit’s URL handling should use OkHttp’s `HttpUrl` for representing an `Endpoint` and for building request URLs, but current behavior does not reliably validate endpoints and/or does not expose the endpoint URL as an `HttpUrl`.

When creating a fixed endpoint via `Endpoint.createFixed(String)`, calling `endpoint.url()` should return an `HttpUrl` instance equivalent to parsing the same string with `HttpUrl.parse(...)`. For example:

```java
Endpoint endpoint = Endpoint.createFixed("http://example.com");
endpoint.url(); // should equal HttpUrl.parse("http://example.com")
```

Invalid endpoint URLs must be rejected eagerly during `Endpoint.createFixed(String)` with a clear error message. For example, passing a non-HTTP(S) URL like:

```java
Endpoint.createFixed("ftp://foo");
```

should throw `IllegalArgumentException` with the exact message:

```
Invalid URL: ftp://foo
```

In addition, request URL construction should correctly combine the endpoint’s base URL with method/annotation paths so that built requests produce the expected final URL string. For example, for a method declared with `@HTTP(method = "CUSTOM1", path = "/foo")`, the built request must have method `CUSTOM1`, no body, and a URL string of:

```
http://example.com/foo
```

Implement the necessary changes so that endpoints are represented by `HttpUrl`, invalid endpoints throw as specified, and request building uses `HttpUrl`-based URL resolution to produce correct request URLs.