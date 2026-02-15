In Ktor’s HttpClient request builder APIs, the convenience methods for specific HTTP verbs (such as `post`, `put`, `delete`, `patch`, `options`, `head`, and their `prepare*` variants) do not reliably set the HTTP method at the correct time.

Currently, when using these APIs, the request builder block can observe an incorrect/default `method` value (or a previously set value), because the verb-specific method assignment happens before/without properly accounting for the builder execution order. As a result, inside the builder lambda, `method` may not be the expected verb, and the resulting outgoing request can also be constructed with an unexpected method depending on subsequent mutations.

The expected behavior is:

- When calling `client.post { ... }`, `client.post("/") { ... }`, and similarly for `put`, `delete`, `patch`, `options`, and `head`, the `method` visible inside the builder block must already be set to the corresponding verb (e.g., `HttpMethod.Post` for `post`).
- When using prepared calls like `client.preparePost { ... }.execute()` and `client.preparePost("/") { ... }.execute()` (and the analogous `preparePut`, `prepareDelete`, `preparePatch`, `prepareOptions`, `prepareHead`), the `method` visible inside the builder block must already be set to the corresponding verb.
- For these verb-specific convenience functions, the request ultimately executed/sent by the client engine must use the corresponding verb as its final HTTP method.
- It must still be possible for user code to override the method inside the builder (e.g., setting `method = HttpMethod.Get`), but the default verb must be applied after the request builder has been executed so that the builder starts with the expected verb method already applied.

Fix the request-building flow so that verb-specific method selection is applied at the correct point in the builder lifecycle for both immediate and prepared request APIs, ensuring the builder observes the correct default method and the executed request uses the correct method.