Creating a JsonAdapter via a JsonAdapter.Factory can trigger infinite recursion and a StackOverflowError when the factory tries to look up (delegate to) an adapter for a type that the same factory is responsible for creating.

This happens in delegation-heavy and/or circular model graphs. For example, with mutually-referential types (like a Team containing Projects that contain Teams), calling `new Moshi.Builder().build().adapter(Team.class)` should produce an adapter that can both serialize and deserialize instances with nested cycles without overflowing the stack.

The failure also occurs when using custom qualifiers/annotations (for example `@Left` and `@Right`) where a factory returns an adapter for `Node` and, while building that adapter, calls back into Moshi to resolve `Node` again (possibly with different annotations). Instead of safely resolving to the in-progress adapter (or otherwise breaking the recursion), Moshi repeatedly re-enters adapter creation until a `StackOverflowError` occurs.

Fix Moshi’s adapter lookup/creation behavior so that:

- When `JsonAdapter.Factory.create(Type type, Set<? extends Annotation> annotations, Moshi moshi)` creates an adapter for a given `(type, annotations)` and, during that creation, asks Moshi to resolve an adapter for the same logical key (including cases where it is the same factory or the type was produced by that factory), Moshi does not recurse indefinitely.
- Adapter resolution must correctly handle circular type graphs during both `toJson()` and `fromJson()`.
- Delegation patterns that involve qualifiers should work correctly: resolving adapters for `Node` annotated with `@Left` and `@Right` must not lead to stack overflow and should serialize/deserialize with the expected structure.

After the fix, typical usage like `Moshi moshi = new Moshi.Builder().build(); JsonAdapter<Team> adapter = moshi.adapter(Team.class); adapter.toJson(team)` and `adapter.fromJson(json)` should complete successfully for nested/circular object graphs, and delegation-heavy custom factories should be able to look up the types they create without causing a `StackOverflowError`.