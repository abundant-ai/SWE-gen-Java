Micronaut’s core nullability annotations currently don’t provide a way to control whether nullability semantics are inherited from interface methods (or superclass methods) onto implementing/overriding methods. As a result, when an interface method parameter is annotated as nullable/non-null, the implementing class’s corresponding method parameter may not be treated as nullable/non-null during introspection unless the implementing method repeats the annotation. This forces downstream tooling (for example, OpenAPI generator plugins) to introduce custom “hard nullable” annotations to get inherited nullability behavior.

Add support for explicitly opting into inheritance handling on Micronaut’s core nullability annotations by introducing a new annotation member named `inherited` on both `io.micronaut.core.annotation.Nullable` and `io.micronaut.core.annotation.NonNull`.

When a method in an interface declares a parameter as `@Nullable(inherited = true)`, an implementing class that overrides/implements that method without explicitly annotating the parameter should still have that parameter treated as nullable by Micronaut introspection (i.e., `Argument.isNullable()` should be `true`). Similarly, when an interface declares `@NonNull(inherited = true)` on a parameter, the implementing method’s parameter should be treated as non-null (i.e., `Argument.isNonNull()` should be `true`) even if the implementing method does not repeat the annotation.

At the same time, existing behavior must remain unchanged when `inherited` is not enabled: an implementing/overriding method should not automatically become nullable/non-null solely because the interface/super method was annotated, unless the annotation indicates it should be inherited.

Also ensure that user-defined/custom nullable annotations that are meta-annotated with Micronaut’s `@Nullable` can be created with Java’s `@Inherited` semantics and used to achieve inherited nullable behavior where desired.

Concrete scenario that must work:

```java
interface ControllerInterface {
  default String inherited(@Nullable(inherited=true) String header1) { return header1; }
  default String inherited2(@NonNull(inherited=true) String header1) { return header1; }
}

class ControllerImplementation implements ControllerInterface {
  @Override
  public String inherited(String header1) { return header1; }

  @Override
  public String inherited2(String header1) { return header1; }
}
```

After compilation/introspection, the `header1` argument of `ControllerImplementation.inherited` must be considered nullable, and the `header1` argument of `ControllerImplementation.inherited2` must be considered non-null, even though the implementation does not redeclare the annotations. Meanwhile, a method parameter annotated with plain `@Nullable` in the implementation should continue to be treated as nullable as it is today.