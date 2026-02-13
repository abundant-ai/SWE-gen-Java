Retrofit currently rejects service methods whose parameters include annotations that Retrofit does not recognize, instead of ignoring them. This breaks interoperability with other libraries and languages (notably Kotlin), which may add extra parameter annotations at compile time. For example, a Kotlin interface method like:

```kotlin
@GET("/users/{user}/repos")
fun listRepos(@Path("user") user: String,
              @Query("page") page: Int): Call<List<Repo>>
```

can end up with additional non-Retrofit annotations on parameters, causing Retrofit to throw an IllegalArgumentException during method parsing/request creation.

Update Retrofit’s method/parameter inspection so that unknown/non-Retrofit annotations on parameters are ignored rather than treated as an error. Retrofit must still correctly detect and enforce its own parameter annotations such as `@Path`, `@Query`, `@QueryMap`, `@Field`, `@FieldMap`, `@Part`, `@PartMap`, `@Body`, `@Header`, and `@Url`, including existing validation rules (e.g., required names, encoding constraints, and mutual exclusivity).

Expected behavior: Service methods should successfully parse and build requests even when parameters have extra annotations not defined by Retrofit, as long as the Retrofit annotations present are valid.

Actual behavior: Adding any additional parameter annotation which Retrofit doesn’t handle causes an IllegalArgumentException during request/method parsing, preventing request creation.