Retrofit’s builder currently only supports configuring the base endpoint using a String, which forces callers who already have an OkHttp `HttpUrl` to convert it to a String. Add support for configuring the endpoint using an `HttpUrl` directly.

When building a `Retrofit` instance, callers should be able to write:

```java
HttpUrl url = server.getUrl("/");
Retrofit retrofit = new Retrofit.Builder()
    .endpoint(url)
    .build();
```

This should behave the same as passing `url.toString()` to `endpoint(String)`.

The change must preserve existing behavior of the built `Retrofit` instance and its dynamic proxies:

- Creating an API interface via `retrofit.create(SomeService.class)` must still work normally when the endpoint was set with an `HttpUrl`.
- The generated service proxy must still correctly support `hashCode()`, `equals(Object)`, and `toString()` (i.e., these calls should not crash and should return sensible values).
- Existing validation behavior must remain unchanged (for example, creating a service for an interface that extends another interface must still throw `IllegalArgumentException` with the message: `Interface definitions must not extend other interfaces.`).

In addition, ensure that all builder configuration methods have corresponding access/behavior in the final `Retrofit` instance such that configurations set on `Retrofit.Builder` are actually reflected after `build()`. The behavior of each builder method and its counterpart on `Retrofit` should be consistent and testable; setting values via the builder should be observable on the built instance in the same way as existing supported configurations.