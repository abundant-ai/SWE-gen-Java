`HttpCallValidatorConfig.handleResponseException()` currently accepts the wrong handler type, which prevents callers from providing a `CallExceptionHandler` consistently across the HTTP client call validation APIs.

The API should allow registering response-exception handlers using the `CallExceptionHandler` type, matching the rest of the call validation/exception handling system. In particular, `HttpCallValidatorConfig.handleResponseException { ... }` must receive a `CallExceptionHandler` (not the older/incorrect handler type), and internally it must be wired so that the handler is actually invoked during request execution when an exception is thrown either from the response pipeline or from the engine.

When multiple handlers are registered via:

- `handleResponseException { cause -> ... }` (registered multiple times)
- `handleResponseExceptionWithRequest { cause, request -> ... }` (registered multiple times)

all registered handlers must be executed exactly once per thrown exception, and the original exception must still propagate to the caller (i.e., the call should still throw the same exception after handlers run).

This needs to work in at least these scenarios:

1) An exception is thrown from the client response pipeline during the transform phase (e.g., while converting the response body). All registered `handleResponseException` and `handleResponseExceptionWithRequest` handlers must run, each receiving the thrown exception, and the request passed to the `...WithRequest` variant must be non-null.

2) An exception is thrown directly by the client engine when executing the request. The registered handlers must still run, with the same guarantees as above.

If a wrapper is used to adapt between handler shapes, it must preserve the expected call semantics (no dropped handlers, no double-invocation, correct exception instance passed through).