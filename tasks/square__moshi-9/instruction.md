Moshi’s adapter resolution for Java collection types is incomplete/inconsistent. When requesting a JsonAdapter for collection interfaces (like Collection, List, Set, and queue/deque types), Moshi should consistently return a working adapter that reads/writes JSON arrays and uses the element adapter for the collection’s generic element type.

Currently, some collection types either fail to get an adapter at all or get an adapter that doesn’t behave correctly for certain collection implementations. This can surface as runtime failures when calling Moshi.adapter(...) with a parameterized collection type, or incorrect behavior when encoding/decoding JSON arrays.

Implement or fix a CollectionsJsonAdapter.Factory (or equivalent factory used by Moshi) so that:

- Moshi.adapter(Type) can create adapters for parameterized collection types, including common interfaces like Collection<T>, List<T>, and Set<T>, and also queue/deque-style collections.
- Decoding a JSON array like ["a","b"] into a Collection<String> (or List<String>, Set<String>, etc.) returns a collection containing those elements, using the delegated JsonAdapter<String> for element conversion.
- Encoding the resulting collection back to JSON produces a JSON array with the same element values (order should be preserved where the target collection type preserves order; for set-like types, it should still produce a valid JSON array of the set’s contents).
- Null handling matches Moshi’s general rules: if the collection type is nullable (boxed/declared type), JSON null should decode to null and null should encode as "null"; otherwise, attempting to decode null into a non-nullable target should throw an IllegalStateException with a message consistent with Moshi’s existing path-aware errors.
- The adapter should correctly handle empty arrays, nested/parameterized element types (for example List<List<String>>), and should propagate JsonDataException/IllegalStateException with accurate JSON path information when an element cannot be decoded.

The goal is that users can reliably use Moshi to serialize and deserialize JSON arrays into standard Java collection types without having to register custom adapters for each collection interface/implementation.