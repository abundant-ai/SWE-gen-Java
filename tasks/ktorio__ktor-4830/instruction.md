Ktor’s dependency injection and DSL APIs have several IDE/DSL-safety and runtime diagnostics issues that need to be fixed.

1) Routing and engine configuration DSL scoping is incorrect because DSL marker annotations are missing or inconsistently applied. In Ktor 3.x this can manifest as nested routing blocks losing proper receiver scoping (for example nested routing calls becoming ambiguous or allowing accidental access to outer receivers), and IDE DSL highlighting/completions behaving incorrectly. The DSL markers must be applied so that routing builders and their handler contexts are correctly segregated, and application/engine configuration DSLs do not leak scope into each other. Concretely, `Route` and `RoutingContext` should be treated as Ktor DSL receivers, and engine configuration receivers like `ApplicationEngine.Configuration` and `EngineConnectorBuilder` should also be treated as Ktor DSL receivers, with `@KtorDsl` usage revised to be consistent and correct.

2) The server DI API currently relies heavily on extension functions and an interface-based registry, which leads to poor IDE UX (harder auto-imports, less discoverable API surface) and also contributes to DSL highlighting issues when using the DI builder/invoke style. The DI registry should be exposed as a concrete, non-extensible API surface (a single `DependencyRegistry` type rather than an interface façade), with the core DI operations moved onto that type so that most DI usage can be accessed via one import: `io.ktor.server.plugins.di.dependencies`.

As part of this change, the DI API must continue to support these behaviors:
- Accessing dependencies via delegated properties (e.g., `val service: GreetingService by dependencies`) must throw `MissingDependencyException` if no matching dependency is declared.
- Declaring dependencies out of order must throw `OutOfOrderDependencyException` when a new declaration is attempted after resolution has already happened (for example: declare A, resolve A, then attempt to declare B).
- Declaring conflicting dependencies for the same key must throw `DuplicateDependencyException`.
- Resolving/creating dependencies must detect circular graphs and throw `CircularDependencyException`.
- When multiple candidates match due to covariance, ambiguous resolution must throw `AmbiguousDependencyException`.
- Providing a lambda whose return type comes from Java (flexible types) or is nullable must not break key inference: a provider returning `T?` should still allow DI to infer and register the non-null `T` key correctly when appropriate, and it should not fail simply because the underlying Kotlin type appears flexible from Java interop.

3) DI exception traceability is currently insufficient for debugging misconfigured dependencies. When dependency validation fails or resolution errors occur, exceptions should include more actionable trace information:
- Include source information indicating where a dependency key was first referenced.
- Include trace details for when dependencies are declared, including any inferred keys produced through covariance mappings.
- When validation finds problems, report a summary of all detected problems rather than only the first one encountered.

The goal is that common DI usage remains simple and discoverable (ideally through a single `dependencies` import), routing/configuration DSL receivers are properly isolated via `@KtorDsl`, and DI failures provide clear, traceable error information while preserving the expected exception types listed above.