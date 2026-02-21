Calling Jackson with UUID values can throw a NullPointerException because the serialization context’s stream write capability set is not initialized in some code paths.

Two common reproductions are:

1) Tree conversion:
```java
ObjectMapper mapper = new ObjectMapper();
JsonNode node = mapper.valueToTree(UUID.randomUUID());
```
This should produce a JsonNode containing the UUID value (typically as a string) and must not throw.

2) Generator-based POJO writing:
```java
JsonMapper mapper = new JsonMapper();
JsonGenerator generator = mapper.createGenerator(new StringWriter());
generator.writeStartObject();
generator.writePOJOProperty("id", UUID.randomUUID());
generator.writeEndObject();
```
This should successfully write an object containing the UUID property and must not throw.

Actual behavior: a NullPointerException is thrown with a message like:

"Cannot invoke \"tools.jackson.core.util.JacksonFeatureSet.isEnabled(...)\" because \"this._writeCapabilities\" is null"

The stack trace originates from `SerializationContext.isEnabled(StreamWriteCapability cap)` being called during UUID serialization (notably via `UUIDSerializer._writeAsBinary(...)`), where `_writeCapabilities` is unexpectedly null.

Expected behavior: `_writeCapabilities` must never cause an NPE when `SerializationContext.isEnabled(...)` is called. UUID serialization must work both for default string form and for binary output when UUIDs are configured/annotated for binary shape (for example via `@JsonFormat(shape = JsonFormat.Shape.BINARY)`), and `ObjectMapper.valueToTree(UUID)` must not trigger capability checks that can crash due to missing generator/capability initialization.