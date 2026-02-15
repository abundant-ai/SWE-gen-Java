`ExtensionContext.Store.CloseableResource` instances are not closed deterministically in JUnit Jupiter. When multiple closeable resources are stored in an `ExtensionContext.Store` (e.g., via `store.put(key, closeable)`), their `close()` methods should be invoked in the inverse order in which the resources were added (LIFO).

Currently, `close()` can be invoked in an effectively random order because the underlying storage does not preserve insertion order (for example, when values are held in a `ConcurrentHashMap`). This causes observable mis-ordering of resource cleanup, which is especially problematic when later resources depend on earlier ones still being available during teardown.

Reproduction scenario:
- In a test, obtain a store such as `extensionContext.getStore(ExtensionContext.Namespace.GLOBAL)`.
- Add three `ExtensionContext.Store.CloseableResource` instances in order: key1, key2, key3.
- Each resource’s `close()` publishes a report entry (or otherwise records its closure).

Expected behavior:
- When the context/store is closed at the end of execution, `close()` must be called in reverse insertion order: the resource stored third closes first, then the second, then the first.
- Example expected closure sequence for inserted keys "1", "2", "3": close "3" then "2" then "1".

Actual behavior:
- The closure sequence is not guaranteed and may appear random; e.g., "1" might close before "3".

Implement deterministic LIFO closing semantics for `ExtensionContext.Store.CloseableResource` while preserving correct store behavior for normal values, including `put()`, `get()`, and `getOrComputeIfAbsent()`, and ensuring that store behavior remains safe under concurrent access. The fix should ensure that inserting closeable resources and later tearing down the context always triggers their closure in strict inverse order of addition.