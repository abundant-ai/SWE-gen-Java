Kotlin code generation for Moshi’s `@JsonClass(generateAdapter = true)` fails (or produces incorrect/invalid code) when the Kotlin package name contains a segment that looks like a class name (for example, a segment starting with an uppercase letter such as `package com.example.Project`).

Reproduce by defining a `@JsonClass(generateAdapter = true)` Kotlin data class in a package like `com.example.Project` (or any package with an uppercase segment that could be interpreted as a type name), e.g.:

```kotlin
package com.example.Project

import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class ClassInPackageThatLooksLikeAClass(val foo: String)
```

Expected behavior: Moshi’s Kotlin codegen should successfully generate a working adapter for the class, and the generated code should reference the target type using the correct package and class name without confusion between package segments and nested/qualified class names.

Actual behavior: codegen misinterprets the package segment that looks like a class name and emits incorrect type/package references, causing generation or compilation failures for the generated adapter.

Fix the code generation so that it correctly treats all package segments as package components (even if they are capitalized / resemble class names) and reliably generates adapters for `@JsonClass(generateAdapter = true)` classes declared in such packages.