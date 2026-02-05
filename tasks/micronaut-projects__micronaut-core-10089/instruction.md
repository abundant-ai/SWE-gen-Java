Micronaut v4 no longer treats the JSON Merge Patch media type `application/merge-patch+json` as JSON during request processing. As a result, controllers that declare `@Consumes("application/merge-patch+json")` (or use `MediaType.APPLICATION_JSON_MERGE_PATCH`) fail to bind the request body, and a PATCH request with `Content-Type: application/merge-patch+json` results in an error like `Required Body [dto] not specified`.

This should work without requiring users to add a manual configuration workaround such as `micronaut.codec.json.additional-types: [application/merge-patch+json]`.

When a controller defines a PATCH endpoint that consumes and produces JSON Merge Patch, Micronaut should:

- Recognize `application/merge-patch+json` as a JSON media type for the purposes of selecting JSON codecs/body readers and binding `@Body` parameters.
- Correctly parse the request body as JSON and bind it to the declared body type (including introspected records/POJOs).
- Correctly set the response `Content-Type` to `application/merge-patch+json` when producing that media type.

Concrete scenario that must succeed: sending a PATCH request to an endpoint with a JSON string body like `{"f":"foo","b":"bar"}`, using both `Content-Type: application/merge-patch+json` and `Accept: application/merge-patch+json`, should return the same JSON payload (or an equivalent object serialized back to the same JSON) and must not throw a missing-body error.

Additionally, `MediaType.of("application/merge-patch+json")` should resolve to the JSON Merge Patch media type constant (`MediaType.APPLICATION_JSON_MERGE_PATCH_TYPE`) similarly to other `+json` subtypes (e.g., `application/json-patch+json`).