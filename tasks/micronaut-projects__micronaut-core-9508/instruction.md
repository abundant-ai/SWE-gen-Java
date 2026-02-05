In Micronaut Framework 4, cloud environment deduction (probing OS/network to infer cloud providers like EC2) is disabled by default. Users need a supported way to re-enable this behavior at runtime via configuration, but setting an environment variable such as `MICRONAUT_ENV_DEDUCTION=true` does not re-enable detection.

When starting an application on a cloud platform (for example AWS Elastic Beanstalk), Micronaut 3 would detect and activate cloud-related environments (e.g. `cloud` and `ec2`). In Micronaut 4, no cloud environments are detected by default, and attempting to turn detection back on via an environment variable should enable it but currently does not.

Implement support for enabling/disabling cloud environment deduction via both:

1) An explicit builder toggle: `ApplicationContext.builder().deduceCloudEnvironment(true|false)` should control whether cloud deduction is attempted.

2) Configuration overrides:
- A system property `micronaut.env.cloud-deduction` set to `true` should cause cloud deduction to be enabled, and set to `false` should disable it.
- An environment variable `MICRONAUT_ENV_CLOUD_DEDUCTION` set to `true` should cause cloud deduction to be enabled (and `false` should disable it).

The method `DefaultEnvironment.shouldDeduceCloudEnvironment()` must reflect the effective setting, with the default being `false` (cloud deduction off) unless overridden by the builder and/or configuration. With no overrides, `shouldDeduceCloudEnvironment()` should return `false`. When explicitly enabled via the builder or via the property/environment variable, it should return `true` and cloud environments should be eligible for deduction.