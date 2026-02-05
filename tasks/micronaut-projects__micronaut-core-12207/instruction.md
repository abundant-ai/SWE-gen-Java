Jackson databind deserialization in Micronaut currently succeeds for some immutable/constructor-based POJOs without explicit Jackson constructor parameter metadata because Micronaut’s BeanIntrospection-based Jackson integration implicitly supplies property names and access for databind. This behavior needs to be removed so that Micronaut behaves like standard Jackson databind.

Problem: When deserializing a class that only has a constructor with parameters (and no default constructor and no setters), Micronaut currently allows databind to map JSON fields to constructor parameters even if the constructor parameters are not annotated. After removing the BeanIntrospection-based Jackson module, such deserialization should no longer work unless the constructor parameters are explicitly annotated with Jackson metadata (e.g., `@JsonProperty`) or otherwise configured via standard Jackson mechanisms.

Reproduction example:

```java
public class Person {
  private final String name;
  private final int age;

  public Person(String name, int age) {
    this.name = name;
    this.age = age;
  }

  public String getName() { return name; }
  public int getAge() { return age; }
}
```

Deserializing JSON like `{"name":"Sally","age":10}` into `Person` should fail under the new behavior (because Jackson databind cannot reliably infer constructor parameter names without explicit metadata). The failure should be consistent with standard Jackson databind constructor-based deserialization when parameter names are not available.

Expected behavior: Deserialization should work when constructor parameters are annotated:

```java
public Person(@JsonProperty("name") String name,
              @JsonProperty("age") int age) { ... }
```

Additionally, native-image users who rely on Jackson databind (instead of Micronaut Serialization) must be able to serialize/deserialize their types by providing reflection metadata in the standard Micronaut way (e.g., marking types for reflective access). Micronaut should not silently depend on the removed introspection-based Jackson module to make databind work in native images.

Update Micronaut so that:
- Jackson databind no longer uses Micronaut BeanIntrospection to bypass Jackson’s normal reflective/property resolution.
- Constructor-based deserialization without `@JsonProperty` (or equivalent standard Jackson configuration) does not succeed merely because a type is introspected.
- Serialization/deserialization in native images with Jackson databind requires explicit reflection metadata, rather than being implicitly supported by the removed module.