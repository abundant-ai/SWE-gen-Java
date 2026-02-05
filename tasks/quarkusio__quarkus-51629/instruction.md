Quarkus Hibernate ORM configuration currently exposes some options (notably schema management strategy) as free-form strings, which means the configuration reference cannot reliably list all allowed values and users don’t get enum-derived documentation/validation. This is inconsistent with other extensions where enum-typed config results in generated docs that enumerate the accepted values.

The Hibernate ORM configuration should use enum-typed configuration mappings for relevant settings (in particular `quarkus.hibernate-orm.schema-management.strategy`) so that:

- The configuration reference can automatically list the allowed values for these properties.
- Setting the property through programmatic config overrides using the Hibernate enum constants works (e.g. using `org.hibernate.tool.schema.Action.SPEC_ACTION_DROP_AND_CREATE` as the value for `quarkus.hibernate-orm.schema-management.strategy`).
- Validation/behavior for offline mode remains correct: when `quarkus.hibernate-orm.database.start-offline=true` is enabled and `quarkus.hibernate-orm.schema-management.strategy` is set to a schema action other than `none` (including `SPEC_ACTION_DROP_AND_CREATE`), application startup must fail with an error message containing:

`When using offline mode with `quarkus.hibernate-orm.database.start-offline=true`, the schema management strategy `quarkus.hibernate-orm.schema-management.strategy` must be unset or set to `none``

- Using enum values for this configuration must not trigger spurious configuration warnings such as “Unrecognized configuration key …” during startup.

The fix should ensure both Hibernate ORM and Hibernate Reactive behave consistently for this configuration: applying the enum-based schema management strategy in offline mode should reliably fail startup with the message above, without suppressed exceptions, and without unrelated configuration-key warnings.