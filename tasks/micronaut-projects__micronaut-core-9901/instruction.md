When a singleton bean method is annotated with both `io.micronaut.scheduling.annotation.Scheduled` and an AOP advice annotation (e.g., an `@Around` advice such as a custom `@Intercepted` that uses a `io.micronaut.aop.MethodInterceptor`), Micronaut can register the scheduled task more than once. This results in the same scheduled method being executed concurrently by different scheduler threads (effectively running twice per interval).

This happens because both the original bean and the proxied/intercepted bean end up being considered for scheduled method processing, so the scheduler registers the same logical task twice.

Reproduction scenario:
- Define a `@Singleton` bean with a method like `void run()`.
- Annotate the method with `@Scheduled(fixedRate = "100ms")`.
- Also annotate the same method (or containing type) with an AOP annotation that causes the bean to be proxied (e.g., `@Intercepted` declared with `@Around` and `@Type(MethodInterceptor.class)`; the interceptor can simply call `context.proceed()`).
- Start an `ApplicationContext` with whatever conditions are necessary to enable the bean and interceptor.

Actual behavior:
- The scheduled `run()` method is invoked more frequently than configured because it is scheduled twice. In a short window (e.g., ~1 second with `fixedRate = "100ms"`), a counter incremented by `run()` can grow well beyond what a single schedule would produce, indicating duplicate registration and concurrent execution.

Expected behavior:
- A `@Scheduled` method must be registered exactly once, even when the declaring bean is proxied due to AOP advice. The scheduler should only schedule the effective contextual bean instance (the one managed/active in the application context) and must not schedule an additional task for the original non-context/proxied counterpart.

Implement the fix so that combining `@Scheduled` with AOP advice does not result in double scheduling. The corrected behavior should ensure that, for a `@Scheduled(fixedRate = "100ms")` intercepted method, the method is executed at approximately the configured rate (i.e., not doubled), and a simple `AtomicInteger` counter incremented by the method remains within a reasonable upper bound after ~1 second of runtime consistent with a single scheduled registration.