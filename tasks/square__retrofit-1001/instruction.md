When using Retrofit’s RxJava adapter with a service method that returns `rx.Observable<T>` (the “body-only” Observable case), non-2xx HTTP responses should be delivered via the Observable’s `onError` channel as an HTTP-specific exception that exposes the HTTP status information.

Currently, when a service method returns `Observable<T>` and the server responds with a non-2xx status (for example 404), the error propagation does not provide a dedicated HTTP exception type that downstream consumers can reliably filter for and from which they can extract the HTTP status code/message and response details.

Implement consistent HTTP error signaling for the body-only Observable case:

- For a service method declared like `@GET("/") Observable<String> body()`, if the HTTP response status is not in the 2xx range, subscribing should terminate with `onError(Throwable)` where the `Throwable` is an `HttpException` (or equivalent HTTP-specific exception type) that:
  - is an `IOException` subclass (so it behaves like a network-layer failure from the perspective of Rx error handling)
  - has a message formatted like `"HTTP <code> <message>"` (e.g., `"HTTP 404 OK"`)
  - allows consumers to access the HTTP status code/message and the full `Response<?>` object.

- For genuine I/O failures (e.g., connection drop / disconnect after request), the emitted error should remain an `IOException` (not wrapped as an HTTP exception).

- Ensure this behavior is specific to the `Observable<T>` (“body”) adaptation: successful 2xx responses still emit the deserialized body and complete normally; non-2xx responses do not emit a body value and instead error with the HTTP-specific exception.

Example expected behavior:

```java
service.body().subscribe(
    value -> { /* only called for 2xx */ },
    err -> {
      // For non-2xx HTTP: err is HttpException (IOException subclass)
      // err.getMessage() == "HTTP 404 OK" (for a 404 response)
      // err exposes status code/message and full Response
    }
);
```
