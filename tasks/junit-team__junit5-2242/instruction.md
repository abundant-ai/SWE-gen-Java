`EngineTestKit` currently executes an `EngineDiscoveryRequest` directly against a single engine, which means `PostDiscoveryFilter`s are not applied. As a result, when users configure post-discovery filtering (for example via `TagFilter.includeTags(...)` / `TagFilter.excludeTags(...)`), those filters are silently ignored when execution is performed through `EngineTestKit`.

This is most visible when running Jupiter tests through `EngineTestKit` with tags: calling something like

```java
EngineTestKit.engine("junit-jupiter")
    .selectors(selectClass(SomeTestClass.class))
    .filters(TagFilter.includeTags("tag1"))
    .execute();
```

should only execute tests whose effective tag set matches the tag expression (including tag-expression keywords such as `any()` and `none()`, and their negations like `!none()` / `!any()`). Instead, today the execution proceeds as if no tag filter was configured, causing tagged and untagged tests to run unexpectedly.

Implement support in `EngineTestKit` so that `PostDiscoveryFilter`s supplied via `EngineTestKit.filters(...)` (or via a `LauncherDiscoveryRequest` passed into the kit) are actually respected during discovery/execution, matching the behavior of the JUnit Platform `Launcher`.

Expected behavior examples:

- If a class has tests tagged with `@Tag("tag1")`, `@Tag("tag2")`, both tags, and also untagged tests, then `TagFilter.includeTags("whatever")` should execute nothing.
- `TagFilter.includeTags("tag1")` should execute only tests tagged with `tag1` (including tests with multiple tags where one is `tag1`) and should not execute untagged tests.
- `TagFilter.includeTags("any()")` and `TagFilter.includeTags("!none()")` should execute all tagged tests but not untagged tests.
- `TagFilter.includeTags("none()")` and `TagFilter.includeTags("!any()")` should execute all untagged tests but not tagged tests.

Also ensure this behavior is consistent when the kit is used in existing Jupiter engine integration scenarios (for example, nested test classes and method/class selectors), i.e., filtering should not break discovery or execution structure and should not be silently ignored.