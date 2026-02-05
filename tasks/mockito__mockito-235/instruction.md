Creating a spy with @Spy can fail when the spied class’s constructor calls an instance method. This is a regression seen when upgrading (e.g., from 2.0.8-beta to 2.0.9-beta) where Mockito started using constructor-based instantiation for @Spy in more cases (instead of always using Objenesis). With the ByteBuddy mock maker, the interceptor is installed only after the instance is constructed, so any virtual method call made from the constructor can be routed through Mockito’s dispatch path before the interceptor is available, leading to a NullPointerException wrapped in a MockitoException.

Reproduction: given a field annotated with @Spy, calling MockitoAnnotations.initMocks(this) should successfully initialize the spy even if the spied type’s no-arg constructor invokes an overridable method.

Example scenarios that must work:

1) Constructor invokes a void method:

```java
class HasConstructorInvokingMethod {
    HasConstructorInvokingMethod() { someMethod(); }
    void someMethod() { }
}

@Spy HasConstructorInvokingMethod hasConstructorInvokingMethod;
MockitoAnnotations.initMocks(this);
```

2) Constructor uses the result of a method call:

```java
class HasConstructorInvokingMethod {
    private final boolean doesIt;
    HasConstructorInvokingMethod() {
        doesIt = someMethod().contains("yup");
    }
    String someMethod() { return "tada!"; }
}

@Spy HasConstructorInvokingMethod hasConstructorInvokingMethod;
MockitoAnnotations.initMocks(this);
```

Expected behavior: MockitoAnnotations.initMocks must complete without throwing, and @Spy fields must be initialized successfully.

Actual behavior: MockitoAnnotations.initMocks throws a MockitoException like “Unable to initialize @Spy annotated field … Unable to create mock instance …” caused by an NPE during construction when the constructor-invoked method is dispatched through Mockito before the interceptor is set.

Fix requirement: Ensure that during construction of ByteBuddy-based mocks/spies, any method invoked before the mock interceptor is installed behaves like a normal call to the real underlying implementation (i.e., does not attempt to use an uninitialized interceptor). This should only affect the narrow window where the instance exists but the interceptor is not yet attached, and should not change normal post-construction interception behavior.