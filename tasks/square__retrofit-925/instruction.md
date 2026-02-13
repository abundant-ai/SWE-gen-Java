Retrofit currently invokes callback methods (e.g., Callback.onResponse / Callback.onFailure) on an internal/default executor when a service interface method returns retrofit.Call<T>. There is no supported way to supply a custom Executor to control which thread executes these callback methods for such Call return types.

Add support for passing an Executor that will be used specifically to invoke callback methods for service methods whose declared return type is Call<T>. This should be configurable when building a Retrofit instance (via Retrofit.Builder) so that users can provide their own callback executor.

The behavior should be:
- When a service method returns Call<T>, and the call is executed asynchronously via enqueue(Callback<T>), the provided callback executor must be used to run the callback methods (both success and failure). The executor should be invoked exactly once per callback invocation.
- Synchronous execution via execute() must not route through the callback executor.
- This configuration must not affect callback invocation for Call instances produced by a CallAdapter (i.e., if a service method returns some other type adapted from Call, Retrofit should not additionally wrap or redirect callback execution for the Call that is passed into the CallAdapter).

Also adjust the default, non-Android Call adapter behavior so that when no special callback executor is needed, the factory returned for Call<T> should not unnecessarily wrap calls just to immediately run callbacks synchronously. In other words, in the default non-Android configuration, adapting Call<T> should effectively return the original Call instance rather than wrapping it with an executor-based delegate that uses a synchronous executor.

Error handling for the Call adapter factory must remain consistent:
- If a service method return type is the raw type Call (not parameterized), throw IllegalArgumentException with the message: "Call return type must be parameterized as Call<Foo> or Call<? extends Foo>".
- If a service method return type is Call<Response<Something>>, throw IllegalArgumentException with the message: "Call<T> cannot use Response as its generic parameter. Specify the response body type only (e.g., Call<TweetResponse>).".

Finally, ensure that responseType() for the Call adapter correctly resolves:
- Call<String> and Call<? extends String> as String.class
- Generic bodies like Call<List<String>> as the full generic type (List<String>).