Retrofit’s refactor to move request-building logic into a “method parsing” phase has introduced regressions in how service method metadata is interpreted and how requests are assembled. The request assembly step should be mostly mechanical, but the refactor must preserve existing behavior and error handling across path parsing, annotation validation, and call adaptation.

There are three user-visible problem areas that need to work exactly as before:

1) Path parameter parsing must correctly identify valid placeholders in endpoint paths.

The static method `MethodInfo.parsePathParameters(String path)` should return the set of unique path parameter names found in `{name}` placeholders, preserving the first-seen encounter order for uniqueness. It must handle these cases:
- Paths with no parameters (e.g., "/", "/foo", "/foo/bar") return an empty set.
- A placeholder with a valid name like `"/foo/bar/{taco}"` returns `{ "taco" }`.
- Multiple placeholders return them in encounter order, de-duplicated: `"/foo/bar/{taco}/or/{burrito}"` returns `{ "taco", "burrito" }`, while `"/foo/bar/{taco}/or/{taco}"` returns `{ "taco" }`.
- Placeholders with invalid names must be ignored (not included in the returned set), such as `{}` or `{!!!}` or `{1}` (names cannot start with a digit).
- Names may include letters, digits (not as first char), underscore, and dash. Examples that must be accepted: `{taco-shell}`, `{taco_shell}`, `{sha256}`, `{TACO}`.

Currently, after the refactor, invalid placeholders may be incorrectly included, duplicate handling/order may be unstable, or some valid names may not be recognized.

2) Request building must preserve annotation validation and request output.

Building an HTTP request from a service interface method must continue to enforce the same validation and produce the same resulting `com.squareup.okhttp.Request`.

Examples of required behavior:
- For a custom method without a body, a method annotated with `@HTTP(method = "CUSTOM1", path = "/foo")` must produce a request with:
  - `request.method()` == "CUSTOM1"
  - `request.urlString()` == "http://example.com/foo"
  - `request.body()` == null
- Only one encoding annotation is allowed. If a method is annotated with both `@Multipart` and `@FormUrlEncoded` (in any order), request creation must throw `IllegalArgumentException` whose message is exactly:
  `"Example.method: Only one encoding annotation is allowed."`

After the refactor, either the validation may not run at parse time, may run at the wrong time, or the exception messages may change. Both the validation timing and the exact message formatting must remain stable.

3) Default Call adapter must keep the same type-checking errors and response type extraction.

`DefaultCallAdapterFactory.get(Type returnType)` must continue to enforce these rules:
- If `get` is called with the raw `Call.class` (non-parameterized), it must throw `IllegalArgumentException` with the exact message:
  `"Call return type must be parameterized as Call<Foo> or Call<? extends Foo>"`
- If the call type is `Call<Response<String>>` (i.e., `Response` is used as the generic parameter), it must throw `IllegalArgumentException` with the exact message:
  `"Call<T> cannot use Response as its generic parameter. Specify the response body type only (e.g., Call<TweetResponse>)."`
- For `Call<String>`, `Call<? extends String>`, and `Call<List<String>>`, the `responseType()` reported by the returned adapter must resolve to `String.class`, `String.class`, and `List<String>`’s generic `Type` respectively.

Right now, the refactor can accidentally change the validation pathway, allow invalid types, or incorrectly resolve wildcard and parameterized generic types.

Fix the refactor so that method parsing and request building preserve these behaviors, including stable ordering/deduping of parsed path parameters and exact exception messages.