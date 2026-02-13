Retrofit currently allows multiple CallAdapter.Factory instances to be registered/used for a single RestAdapter, which leads to ambiguous or inconsistent adaptation of service method return types (e.g., when both the default Call-returning adapter and a user-supplied factory can match). This PR’s intent is to enforce that a RestAdapter uses only a single CallAdapter.Factory.

When building a RestAdapter via RestAdapter.Builder, calling callAdapterFactory(...) should establish the one and only call adapter factory for that RestAdapter. The system must not combine multiple factories, nor allow multiple call-adapter factories to be set in a way that changes behavior depending on ordering.

Expected behavior:
- A RestAdapter built without explicitly setting a call adapter factory should still support service methods whose return type is Call<T> using the built-in/default call adapter behavior.
- A RestAdapter built with a custom call adapter factory should use that factory to adapt return types. For example, if a custom factory handles Call<T>, it should be invoked and its CallAdapter.adapt(Call<...>) should be used.
- If a RestAdapter is configured such that more than one CallAdapter.Factory would be active (for example, attempting to add/set a second factory after one is already configured, or implicitly combining the default factory with a custom one), RestAdapter.Builder.build() (or the configuration call) should fail fast with an IllegalStateException explaining that only a single CallAdapter.Factory is permitted.

Actual behavior to fix:
- It is possible to configure or end up with multiple CallAdapter.Factory instances for one RestAdapter, allowing the default Call adapter and a custom adapter to both participate. This can cause unexpected adapters to be chosen or make it unclear which factory is responsible for a given return type.

Reproduction example (conceptual):
1) Build a RestAdapter with endpoint set.
2) Configure a custom CallAdapter.Factory (e.g., one that returns an adapter when the raw return type is Call).
3) Observe that Call<T> may still be handled by a different factory than expected, or that more than one factory is considered.

Implement the restriction so that RestAdapter.Builder enforces exactly one active CallAdapter.Factory per RestAdapter, while preserving the default behavior when none is provided and preserving custom behavior when one is provided.