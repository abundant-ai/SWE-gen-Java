Quarkus’ build-time reflective hierarchy registration is currently too aggressive: when a type is registered via `ReflectiveHierarchyBuildItem`, Quarkus also ends up registering subclasses and implementors of types that are only *transitively* reachable from that hierarchy (e.g., interfaces implemented by the type, superclasses of the type, and their related type graph). In projects that use widely implemented interfaces or base classes with many subclasses, this causes a large and unintended expansion of reflection registrations.

This excessive registration can have real negative effects on native image builds, including pulling in classes that should not be reachable. One observed failure is a native build error caused by class initialization being triggered for types that get registered due to the transitive explosion, e.g. a build-time failure like:

```
Error: Class initialization of org.jboss.narayana.jta.jms.ConnectionManager failed.
Caused by: java.lang.NoClassDefFoundError: jakarta/jms/JMSException
```

The reflective hierarchy registration behavior needs to be tightened so that only the subclasses and implementors of the *original class being registered* are included, while avoiding registering subclasses/implementors of classes and interfaces that are merely transitively referenced.

When a user registers a class `X` for reflective hierarchy, Quarkus should:
- Register the hierarchy rooted at `X` as intended for reflection purposes.
- Include subclasses of `X` and implementors of `X` (when `X` is an interface), because those are directly related to the root type.
- Not automatically register all implementors of any interface that `X` happens to implement.
- Not automatically register all subclasses of any superclass that `X` extends.

After this change, native builds that previously failed due to unintended reachability (such as the Narayana JMS initialization error above) should succeed, and overall reflection registrations should be reduced to only what is relevant to the explicitly registered root type(s).