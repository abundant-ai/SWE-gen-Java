The Ktor HTTP client HttpCache plugin exposes a `CacheStorage` abstraction for storing and retrieving cached responses keyed by `Url` and a set of `varyKeys`. Currently, there is no supported way to evict cached entries, which makes it impossible to remove a specific cached variant (e.g., one set of Vary headers) or to clear all cached entries associated with a URL.

Extend the `CacheStorage` API to support eviction by adding two suspend methods:

```kotlin
suspend fun remove(url: Url, varyKeys: Map<String, String>)
suspend fun removeAll(url: Url)
```

Implement these methods for all existing `CacheStorage` implementations so that cache entries can be removed correctly:

- `remove(url, varyKeys)` must delete only the cached entry for that exact `url` and `varyKeys` combination, leaving other variants for the same URL intact.
- `removeAll(url)` must delete all cached entries for that `url`, regardless of `varyKeys`.

In addition, ensure any caching/wrapping storage (for example, `CachingCacheStorage` that memoizes results from a delegate `CacheStorage`) remains consistent after removals:

- After calling `remove(url, varyKeys)`, subsequent calls to `find(url, varyKeys)` must return `null`, and `findAll(url)` must no longer include the removed entry.
- After calling `removeAll(url)`, subsequent calls to `findAll(url)` must return an empty list for that URL, and any `find(url, varyKeys)` must return `null`.

The behavior should be consistent across in-memory and file-based storages. For a file-backed storage, storing two cached responses for the same `Url` with different `varyKeys` must result in two retrievable entries via `findAll(url)`, and calling the new removal methods must reduce that set appropriately (from 2 to 1 for `remove`, and from 2 to 0 for `removeAll`).