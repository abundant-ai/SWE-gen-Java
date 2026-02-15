Ktor’s server DI currently cannot resolve dependencies when a DependencyKey is provided without a KType (a “raw” key). This makes it impossible to look up a dependency by key if type information is missing, even when there is an unambiguous registration for that key’s raw class.

When using the DI API with a key that only has a raw class (for example a key built from KClass / TypeInfo without full generic KType), resolution fails with MissingDependencyException, even though an instance was registered for the same underlying type.

Update the DI key mapping / resolution logic so that registrations made with full type information can also be resolved via a “raw” DependencyKey (missing KType). In other words, if a dependency was registered for a type T (including generic versions such as Deferred<String>), resolving with the corresponding raw type (Deferred without generic KType) should still be able to find a matching registration using a default covariance mapping.

Expected behavior:
- DI resolution should succeed when requesting a dependency using a DependencyKey whose KType is absent, as long as there is a compatible registration for the same raw type.
- This should work for common cases used in server DI: interfaces to implementations, delegated components, and coroutine-related types (e.g., Deferred/CompletableDeferred or similar abstractions).
- Existing typed lookups must keep working unchanged; adding raw-type support must not break exact-type matching or cause incorrect ambiguity in normal typed lookups.

Actual behavior:
- Calling DI resolve/get with a DependencyKey that lacks KType results in MissingDependencyException even though a dependency of that raw type is registered.

Implement the missing raw-type support so that:
- The mapping used to match keys considers a default covariance relationship between typed and raw keys, allowing raw keys to access entries registered with full KType.
- Lookup by raw key returns the same instance/provider that a typed key would return for the same underlying raw class.