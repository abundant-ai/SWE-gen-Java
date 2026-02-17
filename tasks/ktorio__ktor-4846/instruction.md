MockEngine currently requires an initial MockRequestHandler at construction time; creating an HttpClient with MockEngine but without providing a handler causes an exception immediately, which makes it hard to set up a client once (e.g., in a @Before) and enqueue handlers later per test.

Add support for initializing a MockEngine with no handlers via a new API: `MockEngine.empty()`.

Expected behavior:
- `MockEngine.empty()` returns an engine instance that can be used to build an `HttpClient` without providing an initial handler.
- Handlers can be added later using the existing engine configuration mechanism (for example, `HttpClient(MockEngine) { engine { addHandler { request -> ... } } }` should continue to work, and the empty engine should also accept handlers added after initialization).
- When a request is executed and at least one handler has been added, request dispatch should behave exactly as it does today (the first matching/queued handler is used according to current MockEngine semantics).
- If a request is executed while there is still no handler available (because none were added, or all were consumed if the engine uses a queue), the engine should fail at request time with the same `error()` behavior/message it used previously when no handler could be used.

The existing constructors/factory that take a handler (e.g., `MockEngine { request -> ... }` and `HttpClient(MockEngine) { engine { addHandler { ... } } }`) must keep their current behavior and must not become more permissive; only the new `MockEngine.empty()` entry point should allow starting with zero handlers.

Example usage that should be possible:
```kotlin
val client = HttpClient(MockEngine.empty())
// later in the test lifecycle
client.config { engine { addHandler { respondOk("ok") } } }
val text = client.get("/").body<String>()
```
If no handler is added before calling `client.get(...)`, the call should throw due to missing handlers (not during client/engine creation).