Dependency Injection (DI) errors in the Ktor server DI plugin are currently hard to debug because exceptions and validation failures don’t provide enough traceability about where a dependency key came from, where it was first referenced, and how it was inferred (for example via covariance mapping). As a result, when an application is misconfigured (missing bindings, duplicate bindings, out-of-order declarations, etc.), the error output does not clearly point to the originating declaration/usage sites and can require manual investigation.

Improve DI exception traceability and validation reporting so that:

1) Missing dependency resolution should report source context. When a dependency is referenced (for example via a delegated property like `val service: GreetingService by dependencies` or via `dependencies.resolve<GreetingService>()`) but no provider exists, the thrown `MissingDependencyException` must include information indicating where that dependency key was first referenced (the source site that triggered/introduced the key into the dependency graph).

2) Declaration tracing must be recorded and surfaced. When dependencies are declared via `dependencies { provide<T> { ... } }`, DI should record trace details for each declaration and include them in errors when relevant. This trace must also include any inferred/derived keys created through covariance mapping (for example, if providing an implementation implies availability through an interface or other mapped key, the trace should show that inference rather than making the key appear “magically”).

3) Validation should summarize all discovered problems. When running DI validation (the validation step that checks the configured dependency graph), if multiple problems exist, the reported failure should include a summary of all problems found, rather than failing fast with only the first one. The summary should be readable and should still preserve per-problem traceability (which key is problematic, what kind of problem it is, and the associated source/declaration traces).

The improved diagnostics must work for the common DI failure modes exposed by the API, including:
- Resolving a type with no provider (throws `MissingDependencyException`).
- Declaring dependencies out of order such that later declarations violate DI’s ordering rules (throws `OutOfOrderDependencyException`).
- Declaring conflicting/duplicate providers for the same key (throws `DuplicateDependencyException`).

After the change, a developer encountering these exceptions should be able to understand (from the exception message/details alone) which dependency key failed, where it was first referenced, where relevant providers were declared (or inferred), and—during validation—see all configuration problems at once.