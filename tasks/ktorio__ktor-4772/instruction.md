When Ktor HttpClient uses SavedBodyPlugin to make the response body replayable, some other client plugins break this behavior by wrapping the call/content in a way that bypasses the saved-body mechanism. This shows up when combining plugins like Logging (via ResponseObserver) or ContentEncoding with any feature that reads the response body more than once (for example, logging the body and then letting user code read it, or reading in an HttpResponseValidator).

Actual behavior:
- Installing ResponseObserver (used by Logging) together with SavedBodyPlugin can cause the response body to be consumed and become non-replayable. Subsequent reads fail or produce empty/incorrect body.
- In some scenarios, Logging combined with reading the body in validation/exception paths can trigger a "Content-Length mismatch" error due to the body being read/rewrapped incorrectly.
- ContentEncoding is not compatible with saved responses (SaveBodyContent): after decoding/wrapping, the saved body mechanism is neutralized and the body cannot be re-read reliably.

Expected behavior:
- With SavedBodyPlugin installed, an HttpResponse body must remain replayable even if ResponseObserver/Logging is installed and observes/logs the response.
- Reading the response body multiple times via HttpResponse.bodyAsText() (or body<String>()) must return the same content each time when the response is saved.
- Logging should be able to log response bodies (including in exception scenarios during response transformation) without preventing later body reads by user code.
- Combining ContentEncoding with SavedBodyPlugin must still allow multiple reads of the decoded response body; decoding must not disable the saved-body behavior.

Reproduction scenario to support:
- Configure an HttpClient with a mock engine returning a small body (e.g., "Hello"). Install SavedBodyPlugin and ResponseObserver (or Logging). In the onResponse callback, read/log the response body, and then in user code read the body again. Both reads must succeed and return identical content.
- Configure Logging at a verbose level that reads/logs the response body, and add an interceptor that throws during response transformation after a response is received. Logging should still log the response body, the exception should still propagate to the caller, and the client must not fail with "Content-Length mismatch" due to the logging/validation reading the body.
- Configure ContentEncoding along with SavedBodyPlugin and ensure that reading the decoded body multiple times works (first read and second read both return the same decoded content).

Implement the necessary changes so that plugins that wrap calls/contents (notably ResponseObserver and ContentEncoding) remain compatible with SavedBodyPlugin and do not turn replayable saved responses back into one-shot streams.