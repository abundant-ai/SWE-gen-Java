The retrofit-mock module has a flaky timing-related failure on Windows when simulating delayed and erroring calls. In some runs, a call configured to be delayed by 100ms completes slightly early (e.g., 99ms), causing an assertion failure like:

java.lang.AssertionError: Expecting: <99L> to be greater than or equal to: <100L>

This happens when using the mock infrastructure to create Calls that intentionally delay completion and/or convert HTTP exceptions into error results. The behavior should be deterministic and stable across platforms, including Windows, so that a configured delay is always respected.

When using MockRetrofit (created via MockRetrofit.from(retrofit, executor)) and configuring delay/variance/error behavior, the following must hold:

- Delay validation: calling mockRetrofit.setDelay(-1, TimeUnit.SECONDS) must throw IllegalArgumentException with message "Amount must be positive value." Calling mockRetrofit.setDelay(Long.MAX_VALUE, TimeUnit.SECONDS) must throw IllegalArgumentException with a message starting with "Delay value too large.".
- Variance validation: calling mockRetrofit.setVariancePercent(x) where x < 0 or x > 100 must throw IllegalArgumentException with message "Variance percentage must be between 0 and 100.".
- Error rate validation: calling mockRetrofit.setErrorPercent(x) where x < 0 or x > 100 must throw IllegalArgumentException with message "Error percentage must be between 0 and 100.".
- For delayed calls (including ones which ultimately fail), the elapsed time observed by the caller should never be less than the configured minimum delay. If a delay of 100ms is configured (with zero variance), the call must not complete in under 100ms.
- When a synchronous call results in an HTTP exception, the mocking layer should consistently treat it as an error outcome (rather than surfacing timing-related behavior differences), and this should not be flaky across repeated runs.

Currently, on Windows the delay logic can under-sleep or otherwise allow completion slightly before the configured delay, leading to intermittent build failures. Update the mock call creation/delay mechanism so that delayed and erroring Calls reliably enforce the minimum delay and behave consistently across platforms.