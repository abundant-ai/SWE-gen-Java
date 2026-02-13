Retrofit’s internal architecture for parsing service interface methods and invoking them needs to be updated so that all mutability during method parsing is temporary, and the resulting representation used at runtime is immutable.

Currently, creating a service implementation via `Retrofit.create(Class)` can rely on parsing state that is mutable or shared in a way that leads to incorrect behavior or instability when building or invoking methods. The desired behavior is that method parsing produces an immutable runtime object (called `MethodInvoker`) that contains everything needed to execute the method without further mutation.

The implementation must preserve existing public behavior and error messages around method parsing and call adaptation. In particular:

- `RequestFactoryParser.parsePathParameters(String)` must correctly parse and return the set of unique path parameter names from a URL path template. It must handle valid names like `{taco}`, `{taco-shell}`, `{taco_shell}`, `{sha256}`, `{TACO}`, and multiple parameters in a path, and it must ignore invalid placeholders like `{}` or `{!!!}` or `{1}` (name cannot start with a digit). Duplicate parameter names in the path should only appear once in the resulting set.

- `Retrofit.create(Class)` must continue to support normal Java `Object` methods (`hashCode`, `equals`, `toString`) on the created proxy instance.

- `Retrofit.create(Class)` must reject interface definitions that extend other interfaces by throwing `IllegalArgumentException` with the message: `"Interface definitions must not extend other interfaces."`

- The default call adapter behavior must remain consistent:
  - `DefaultCallAdapterFactory.get(Type)` must throw `IllegalArgumentException` with the message `"Call return type must be parameterized as Call<Foo> or Call<? extends Foo>"` when given a raw `Call` type.
  - It must throw `IllegalArgumentException` with the message `"Call<T> cannot use Response as its generic parameter. Specify the response body type only (e.g., Call<TweetResponse>)."` when the `Call` is parameterized with `Response<T>`.
  - For `Call<String>`, `Call<? extends String>`, and nested generic body types (e.g., `Call<List<String>>`), `responseType()` must resolve to the correct body type.

The refactor must ensure that method parsing and invocation remain correct under repeated calls and across different service methods, with `MethodInvoker` (or equivalent runtime representation) being immutable and safe to reuse once created. All existing service method validation, return type handling, and request construction semantics must remain the same after the architectural switch.