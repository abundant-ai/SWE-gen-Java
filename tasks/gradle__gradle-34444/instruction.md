Project equality is inconsistent when isolated projects are enabled, and project wrappers can break identity semantics.

When isolated projects are enabled, comparing a project to itself can return false. For example, in a build script:

```kotlin
println(project.rootProject == project.rootProject)
```

Expected behavior: this prints `true` (a project should compare equal to itself).

Actual behavior: with isolated projects enabled, it can print `false`, indicating `equals()` is not symmetric/consistent across project instances and wrappers.

In addition, Gradle’s “vintage mode” project wrapping needs to be supported again via `LifecycleAwareProject`, but without reintroducing the historical problems where wrappers did not preserve the wrapped project’s lifetime and could cause early collection when used as keys in weak maps.

Implement consistent identity-based equality for projects by defining `ProjectInternal` equality to be based on the project identity (so wrappers and underlying runtime implementations compare consistently). This must ensure:

- Reflexivity: `p == p` is always true.
- Symmetry: if a wrapper compares equal to the wrapped project, the wrapped project must compare equal to the wrapper.
- Transitivity across multiple wrappers around the same project identity.
- `hashCode()` is consistent with `equals()` so hashed collections behave correctly.
- `LifecycleAwareProject` wrapping in vintage mode does not break identity equality and keeps wrapper lifetime aligned with the wrapped project lifetime (wrappers must not allow the wrapped project to be collected while the wrapper is still reachable).

After the fix, the equality behavior should be stable regardless of whether isolated projects are enabled, and wrapper/project instances representing the same logical project should behave as the same key in maps/sets.