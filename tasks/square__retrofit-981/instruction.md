Retrofit’s RxJava integration currently supports only `rx.Observable` return types. When a service interface method returns RxJava’s experimental `rx.Single<T>`, Retrofit fails to create the service or fails to adapt the call because `Single` is not recognized/handled by the RxJava call adapter.

Implement optional support for `rx.Single` as a valid return type for network requests, alongside existing `Observable` support.

When building Retrofit with `RxJavaCallAdapterFactory.create()` and defining a service like:

```java
interface Service {
  @GET("/") Single<String> singleBody();
  @GET("/") Single<Response<String>> singleResponse();
  @GET("/") Single<Result<String>> singleResult();
}
```

calling these methods should behave analogously to their `Observable` counterparts:

- `Single<String>` (body):
  - On HTTP 2xx: emit exactly one item (the converted body) and terminate successfully.
  - On HTTP non-2xx (e.g., 404): terminate with an `HttpException` whose message includes the HTTP status (e.g., `"HTTP 404 OK"`).
  - On network I/O failure (e.g., disconnect): terminate with the underlying `IOException`.

- `Single<Response<T>>` (raw response):
  - Always emit exactly one `Response<T>` and terminate successfully, regardless of HTTP status code.

- `Single<Result<T>>` (result wrapper):
  - Always emit exactly one `Result<T>` and terminate successfully.
  - For HTTP non-2xx responses, the `Result` should represent the HTTP error (not throw).
  - For network failures, the `Result` should contain the thrown `IOException` (not throw).

In addition, the Retrofit mocking behavior adapter for RxJava must also support `Single` return types.

Given a mock service implementation that returns `Single.just("Hi!")` and a `Behavior` configuration that can apply delay, variance, and failure percentage, adapting the service through `RxJavaBehaviorAdapter.create()` should:

- For `Single<T>` methods, apply the same behavior rules as for `Observable<T>` methods.
- When behavior is configured for 100% failure after a delay, subscribing to the returned `Single` must:
  - not emit a success value,
  - call `onError` with exactly `behavior.failureException()`,
  - and only do so after at least the configured delay.

Because `rx.Single` is experimental and may not be present at runtime, support must be optional: projects using the RxJava adapter without `Single` available should continue to work without `ClassNotFoundException` or other linkage errors unless `Single` is actually used as a return type.