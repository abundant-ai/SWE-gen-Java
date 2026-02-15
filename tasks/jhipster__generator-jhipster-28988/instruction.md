When using the Spring Boot generator’s source API, there is currently no supported way to programmatically add a YAML “document” into an application YAML configuration (for example, adding a block under `spring.application.name`). This makes it hard for tasks/blueprints to safely contribute YAML configuration in a structured way.

Implement a new source API method named `addApplicationYamlDocument` that can be called from a generator task via the provided `source` object. Calling this method with YAML content like:

```yaml
spring:
  application:
    name: myApp
```

should result in that YAML being added as a document to the generated application YAML configuration output.

The method must behave consistently when invoked during a generator run (including when invoked from a `postWriting` task). It should accept a string containing YAML content and ensure the resulting configuration is valid YAML and preserves the intended nested structure. If the application YAML already exists, adding a document should not corrupt existing YAML; it should append/add a new document in a YAML-document-safe manner (using the standard YAML document separator semantics) or otherwise integrate without breaking the file.

Also ensure the method is exposed on the Spring Boot generator’s `source` API alongside existing helpers like `addApplicationPropertiesClass`, so that `source.addApplicationYamlDocument(...)` is defined and callable during generator execution.