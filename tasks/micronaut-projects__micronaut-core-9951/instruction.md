Micronaut 4.x no longer recognizes certain JSON-derived media types (notably JSON Patch and Merge Patch) as JSON for request body decoding. As a result, controller methods that consume these media types fail to bind the request body and return a 400 error with the message `Required Body [dto] not specified`.

Reproduce with a controller endpoint like:
```java
@Patch(value = "/", consumes = "application/json-patch+json")
PatchOperation patch(@Body PatchOperation dto) {
    return dto;
}
```
(or similarly with `consumes = "application/merge-patch+json"`). When a client sends a PATCH request with header `Content-Type: application/json-patch+json` (or `application/merge-patch+json`) and a valid JSON body, Micronaut should decode the JSON and populate the `@Body` argument.

Expected behavior: Requests with `Content-Type: application/json-patch+json` and `Content-Type: application/merge-patch+json` should be treated as JSON requests by Micronaut’s JSON codec/content negotiation. `@Body` binding should work the same as for `application/json`, and the controller should receive a populated body object.

Actual behavior: With these content types, Micronaut does not treat the request as JSON, so body decoding is skipped and the framework responds with HTTP 400 and the error `Required Body [dto] not specified`.

Implement support so that JSON Patch and Merge Patch content types are recognized as JSON in Micronaut 4.x without requiring users to configure `micronaut.codec.json.additional-types`. This should include `application/json-patch+json` (available as `MediaType.APPLICATION_JSON_PATCH`) and `application/merge-patch+json`, and should ensure both request consumption and response production work when those media types are used in `@Consumes`/`@Produces` and in `Content-Type`/`Accept` headers.