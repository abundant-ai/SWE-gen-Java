The Control API is currently coupled to generator-specific functionality by exposing/depending on a webapp translation helper (getWebappTranslation). This violates the intended design where the Control layer should be generic and not depend on generator internals, and it also introduces unnecessary generics in the Control API.

Update the internal architecture so that getWebappTranslation is provided by (and accessed through) the Application layer rather than the Control layer, while keeping generator behavior unchanged.

When generators run with a provided shared application object (for example via a sharedApplication-like injection), generators must still be able to call a function named getWebappTranslation() on the shared application and receive the translation result. This is relied upon across different generator scenarios, including running the main app generator with interactive answers, generating entities (including regeneration and single-entity generation), and generating client applications (including gateway-related configurations).

Expected behavior:
- The Control API should no longer expose or require generator-specific helpers like getWebappTranslation, and should avoid generics introduced solely to support this helper.
- The Application layer should own the getWebappTranslation capability and make it available to generators through the shared application interface.
- Existing generator flows that depend on sharedApplication.getWebappTranslation() must continue to function without errors and without changing their external invocation pattern.

Actual problem to fix:
- The Control layer currently depends on getWebappTranslation, making it generator-specific and preventing the Control API from being clean/generic. Refactor the API boundary so Control is independent, but ensure sharedApplication.getWebappTranslation() remains callable by generators and continues returning the expected translation content.