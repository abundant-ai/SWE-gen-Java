Micronaut’s JSON handling supports media types beyond `application/json` (for example `application/problem+json`, `application/json-feed+json`, etc.). Currently, the list of these built-in “additional JSON media types” is not defined in a single authoritative place, and some HTTP JSON message handlers advertise `@Produces`/`@Consumes` values that can drift from the set of media types actually supported by the JSON codec.

This inconsistency causes problems when a client sends an `Accept` or `Content-Type` header using one of the additional JSON media types: the JSON codec may support the media type, but the handler annotations may not include it (or vice versa), leading to incorrect content negotiation and unexpected behavior.

Unify the definition of built-in additional JSON media types by introducing a constant on `io.micronaut.json.codec.JsonMediaTypeCodec` (named `JSON_ADDITIONAL_TYPES`) that represents the default additional JSON media types supported by the codec. The JSON codec’s `getMediaTypes()` / `mediaTypes` must include:

- `application/json`
- every media type in `JsonMediaTypeCodec.JSON_ADDITIONAL_TYPES`
- any user-configured extra types from the `micronaut.codec.json.additional-types` configuration property

The behavior must avoid duplicates: if a user configures an additional type that is already part of the built-in set, it must not inflate the resulting media type list.

Additionally, ensure that the framework’s JSON message handlers advertise exactly the same set of media types as the codec via their `@Produces` and `@Consumes` annotations. In particular:

- `io.micronaut.json.body.JsonMessageHandler` must have `@Produces` and `@Consumes` string values that match the string representations of `JsonMediaTypeCodec.getMediaTypes()`.
- `io.micronaut.http.netty.body.NettyJsonHandler` must have `@Produces` and `@Consumes` string values that match the string representations of `JsonMediaTypeCodec.getMediaTypes()`.

Example scenario that must work: when a controller produces JSON and a client sends `Accept: application/json-feed+json`, the response should be encoded as JSON and the `Content-Type` response header should contain `application/json-feed+json`.

After the fix, creating an `ApplicationContext` with `micronaut.codec.json.additional-types` set (e.g. `['text/javascript', 'text/json']`) must result in a JSON codec whose media types include `application/json` and `text/javascript`, and where `text/json` does not create a duplicate if it is already part of the built-in JSON additional types set.