When compiling Micronaut code using the KSP-based Kotlin processing pipeline, annotation names are currently recorded in annotation metadata using the annotation’s canonical name. This causes incorrect behavior for nested/inner annotations because Micronaut’s annotation metadata is expected to use the JVM binary name format (with `$` for nested types), which is also what other Micronaut language processors produce.

As a result, annotations and stereotypes that reference inner annotations cannot be reliably detected via Micronaut’s annotation/introspection APIs. For example, given an annotation `MyAnn` that contains an inner annotation `MyAnn.InnerAnn`, and a class annotated with `@MyAnn.InnerAnn`, the compiled introspection/metadata should report the stereotype name as `test.MyAnn$InnerAnn`. Currently it is stored using a canonical-style name (e.g., `test.MyAnn.InnerAnn`), so lookups by the expected binary name fail.

Fix the KSP implementation so that whenever annotation names are stored into Micronaut annotation metadata, the binary name is used instead of the canonical name. After the change, the following behaviors must work when using KSP-generated metadata:

- A class annotated with `@MyAnn` must be discoverable via `hasAnnotation("test.MyAnn")`.
- A class annotated (directly or via stereotype) with an inner annotation `@MyAnn.InnerAnn` must be discoverable via `hasStereotype("test.MyAnn$InnerAnn")`.

The core requirement is: inner/nested annotation types must be represented with `$` separators in stored metadata names, matching JVM binary naming, so that runtime/introspection annotation queries behave consistently across processors.