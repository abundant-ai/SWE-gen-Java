OkHttp’s Kotlin API does not currently provide ergonomic overloads for configuring timeouts using `kotlin.time.Duration`. Users configuring an `OkHttpClient.Builder` must use the Java-style `(long, TimeUnit)` overloads, which is inconvenient and inconsistent with other Kotlin-first APIs.

Add overloads on `OkHttpClient.Builder` that accept `kotlin.time.Duration` for the standard timeout setters (for example: `connectTimeout(Duration)`, `readTimeout(Duration)`, `writeTimeout(Duration)`, and `callTimeout(Duration)`), and ensure they behave identically to the existing `(long, TimeUnit)` overloads.

The Duration-based overloads must validate and convert durations to millisecond precision with the same semantics and error messages as the existing time-unit-based validation:

- A duration of `0.milliseconds` is valid and should result in an internal timeout value of `0`.
- A positive duration like `1.milliseconds` is valid and should convert to `1`.
- Negative durations must fail with an `IllegalStateException` whose message is exactly `"<name> < 0"` (for example `"timeout < 0"` when the parameter name is `timeout`).
- Durations that are positive but too small to be represented at millisecond precision (for example `1.nanoseconds`) must fail with an `IllegalArgumentException` whose message is exactly `"<name> too small"`.
- Durations that are too large to fit in the supported millisecond range must fail with an `IllegalArgumentException` whose message is exactly `"<name> too large"`. In particular, values larger than `Int.MAX_VALUE` milliseconds (for example `(1L + Int.MAX_VALUE).milliseconds`) must trigger this.

Expose/implement a Duration-based helper equivalent to the existing duration checking routine so that calling something like `checkDuration("timeout", duration)` returns an `Int` millisecond value when valid and throws with the messages above when invalid.

Expected behavior: Kotlin callers can use `kotlin.time.Duration` directly on `OkHttpClient.Builder`, and invalid durations produce the same exception types and exact messages as the legacy overloads.
Actual behavior: Duration overloads are missing (or duration validation/conversion does not match the established semantics), preventing Kotlin Duration usage or producing inconsistent results/exceptions.