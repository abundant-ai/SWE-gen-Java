Passing a template model containing null values to the Ktor server Thymeleaf integration currently fails due to the model being typed/validated as non-null values (for example, Map<String, Any>). Thymeleaf itself supports null model attributes, and Ktor users can already make this work only by using unsafe casts, but the plugin’s public API prevents it.

When responding with ThymeleafContent, it should be possible to include nullable entries in the model, such as mapOf("title" to null), without throwing an exception or rejecting the model. Rendering should proceed normally, with Thymeleaf receiving the attribute with a null value (so template expressions can handle it using Thymeleaf’s standard null semantics).

Concretely, update the Thymeleaf plugin/content API so that:
- The model passed to ThymeleafContent can contain null values (e.g., Map<String, Any?>).
- The call call.respond(ThymeleafContent(templateName, model, etag)) must work when model includes null values.
- Existing behavior remains unchanged for non-null models, including correct Content-Type (text/html with UTF-8) and ETag behavior when an ETag is provided.

Example scenario that should work:

```kotlin
val model = mapOf(
    "id" to 1,
    "title" to null
)
call.respond(ThymeleafContent("template", model, "e"))
```

Expected: the response is rendered successfully as HTML; the ETag header is set to "\"e\"" when provided; and there is no crash due to null values in the model.

Actual (current): the API/type constraints prevent passing null values without unsafe casting, and attempts to include nulls are rejected at compile time or fail during model handling.