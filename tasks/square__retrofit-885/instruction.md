Retrofit currently allows service interface methods whose response type includes a method type variable (e.g., `<T> Call<T>` or `<T extends BaseModel> T`). At runtime, Retrofit cannot resolve a concrete type for `T`, so deserialization falls back to generic map types (e.g., Gson producing `LinkedTreeMap` / `LinkedHashMap`). This leads to runtime failures such as:

`java.lang.ClassCastException: java.util.LinkedHashMap cannot be cast to com.example.DishListResponse`

This is especially common when defining a generic base service method like:

```java
public interface BaseHttpService {
  @POST("/{requestUrl}")
  <T> void post(@Path("requestUrl") String requestUrl,
      @QueryMap Map<String, Object> map,
      Callback<T> callback);
}
```

and then calling it with a callback whose declared type is concrete (e.g., `Callback<DishListResponse<DishDetail>>`). Despite the callback having a concrete type argument, Retrofit still treats the service method as returning/producing `T` and cannot reliably infer the real type.

Retrofit should reject these APIs at service creation time (when `RestAdapter.create(...)` is called) by throwing an `IllegalArgumentException` if a response type contains an unresolvable type variable. This includes, but is not limited to:

- Methods declared with a type parameter used in the response type, such as `<T> Call<T> none()`.
- Methods where the type variable has bounds, such as `<T extends ResponseBody> Call<T> upper()`.
- Methods where the type variable appears nested inside the response type, such as `<T> Call<List<Map<String, Set<T[]>>>> crazy()`.

The error message should clearly indicate that type variables are forbidden in response types (e.g., that the return/response type must be fully resolved to concrete types), so developers discover the problem early instead of getting late `ClassCastException` during callback invocation.

At the same time, Retrofit must continue to allow concrete response types like `Call<ResponseBody>` and other valid parameterized types whose type arguments are not type variables.

Implement validation in the service method parsing/creation logic (triggered by `RestAdapter.create(...)`) so that attempting to create a service interface with any of the disallowed method signatures fails fast with `IllegalArgumentException`, while valid interfaces still work normally.