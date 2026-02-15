The generator’s Java source-editing API is missing support for programmatically adding enum constants to an existing Java enum file. A new method `addItemsToJavaEnumFile(javaFilePath, options)` needs to be implemented on the `source` API so that blueprints and post-writing tasks can reliably insert enum values into a Java `enum`.

When `addItemsToJavaEnumFile` is called with `options.enumValues` (an array of strings), it should update the target enum source file by inserting those enum constants at the designated needle comment `// jhipster-needle-add-item-to-enum - JHipster will add new enum values here`.

The method must handle these scenarios:

1) Empty enum constant list (enum has only a `;` before the needle). Example initial content:

```java
package com.example;
public enum Test {
    ;
    // jhipster-needle-add-item-to-enum - JHipster will add new enum values here
}
```

Calling:

```js
source.addItemsToJavaEnumFile('.../Test.java', {
  enumValues: ['VALUE', 'VALUE_WITH_PARAMS(1, "value")'],
});
```

should result in the enum containing the new values before the semicolon, properly comma-separated and formatted, e.g. the enum constants section becomes something like:

```java
public enum Test {
    VALUE,
    VALUE_WITH_PARAMS(1, "value");
    // jhipster-needle-add-item-to-enum - JHipster will add new enum values here
}
```

2) Enum already has existing values. The method should append new values after existing ones, preserving valid Java enum syntax (commas between constants, semicolon terminating the list), and keep the needle comment in place.

3) Idempotency / duplicates. If `enumValues` includes a value that already exists in the enum constants list (string match on the enum constant token as written, including parameterized forms), it should not be added again.

4) Parameterized enum values. Values like `VALUE_WITH_PARAMS(1, "value")` must be inserted verbatim as enum constants (no escaping changes), and still maintain correct comma/semicolon placement.

If the file does not contain the enum needle comment, the method should fail with a clear error indicating it cannot find the insertion point (rather than silently doing nothing).

The result must be compilable Java and should keep stable formatting/indentation consistent with the surrounding code (4-space indentation as in the examples).