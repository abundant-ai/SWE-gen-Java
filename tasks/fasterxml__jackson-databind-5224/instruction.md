When deserializing a POJO that uses `@JacksonInject`, injection can be applied more than once for the same logical property, and in some cases a later injection step incorrectly overrides a value that was already provided by input/creator construction.

Two problematic scenarios need to be fixed:

1) Duplicate injection when both a creator parameter and a field correspond to the same injection id.

Example:
```java
static class Dto {
  @JacksonInject("id")
  String id;

  @JsonCreator
  Dto(@JacksonInject("id") @JsonProperty("id") String id) {
    this.id = id;
  }
}
```
If `InjectableValues` is implemented to return a different value each time `findInjectableValue(...)` is called (for example returning `"id1"`, then `"id2"` on subsequent calls), deserializing with:
```java
Dto dto = readerFor(Dto.class).with(injectables).readValue("{}");
```
should result in `dto.id` being the first injected value (`"id1"`). Currently, injection is executed twice and the second injected value overwrites the first, so `dto.id` ends up as `"id2"`.

The deserializer must ensure that, for a given injectable id/property, injection logic is not executed twice (and does not overwrite the value set by the earlier injection/creator step).

2) `useInput = OptBoolean.TRUE` is not respected when a value is provided via creator/input, because field/setter injection later overwrites it.

Example:
```java
protected static class Some {
  private String field1;

  @JacksonInject(value = "defaultValueForField2", useInput = OptBoolean.TRUE)
  private String field2;

  public Some(@JsonProperty("field1") String field1,
              @JsonProperty("field2")
              @JacksonInject(value = "defaultValueForField2", useInput = OptBoolean.TRUE) String field2) {
    this.field1 = field1;
    this.field2 = field2;
  }

  public String getField1() { return field1; }
  public String getField2() { return field2; }
}
```
Given `InjectableValues` provides `"somedefaultValue"` for id `"defaultValueForField2"`:

- Deserializing `{"field1":"field1value"}` should yield `field2 == "somedefaultValue"`.
- Deserializing `{"field1":"field1value", "field2":"field2value"}` should yield `field2 == "field2value"`.

Currently, the second case can incorrectly end up with `field2 == "somedefaultValue"` because after the creator sets the constructor value, a later injection pass still runs and overwrites the already-populated property/field.

Fix deserialization so that when `@JacksonInject(useInput = OptBoolean.TRUE)` is used and input provides a value (including via creator construction), the injected default does not override that input value. This must also hold for final fields initialized in the constructor: a later injection step must not mutate/overwrite the constructor-initialized value.

The end result should be:
- Injection is applied at most once per logical injectable id/property during a single deserialization.
- When both creator-based injection and field/setter injection could apply to the same logical property, the field/setter injection must not cause a second injection or overwrite the already-set value.
- `useInput=OptBoolean.TRUE` must reliably prefer JSON/input values over injected defaults, even when an injectable annotation exists both on a constructor parameter and on the corresponding field.