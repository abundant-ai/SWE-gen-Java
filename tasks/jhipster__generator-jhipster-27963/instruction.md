After upgrading generated applications to Spring Boot 3.4.0, the generated test infrastructure no longer compiles and/or fails at runtime due to changes in Spring’s testing and security APIs. Several generated integration/security tests rely on outdated mocking/test-configuration annotations and JWT utility wiring that are incompatible with Spring Boot 3.4.

The generated application should work with Spring Boot 3.4.0 such that the following components compile and behave correctly:

1) JWT test utilities

The helper class JwtAuthenticationTestUtils must be able to create a valid signed JWT string for use in authentication tests.

- The method JwtAuthenticationTestUtils.createValidToken(String jwtKey) must return a token equivalent to calling createValidTokenForUser(jwtKey, "anonymous").
- The method JwtAuthenticationTestUtils.createValidTokenForUser(String jwtKey, String user) must produce a JWT with:
  - subject set to the provided username
  - issued-at set to “now”
  - expires-at set to now + 60 seconds
  - a claim named SecurityUtils.AUTHORITIES_KEY containing a list with "ROLE_ADMIN"
  - a JWS header using SecurityUtils.JWT_ALGORITHM
- Token encoding must work with Spring Security’s JwtEncoder/JwtEncoderParameters and NimbusJwtEncoder setup in the generated app.
- In MVC (non-reactive) setups, the test configuration must still expose a HandlerMappingIntrospector bean so Spring Security MVC configuration can initialize correctly.

2) Mockito-based bean overriding in integration tests

Spring Boot 3.4 introduces/standardizes bean override support for tests. Generated integration tests that mock Spring beans must use the correct annotation so that mocks are actually injected into the application context.

Two common scenarios must work:

- OAuth2 user-info claim conversion
  - The integration test creates a CustomClaimConverter using a ClientRegistration from ClientRegistrationRepository and a RestTemplate.
  - The RestTemplate used by CustomClaimConverter must be mockable in the Spring test context.
  - The mock must correctly intercept calls like restTemplate.exchange(..., HttpMethod.GET, ..., ObjectNode.class) and allow stubbing of responses.
  - CustomClaimConverter must handle user-info payloads containing fields like name, family_name, name suffix, email, and roles/authorities mappings, without failing due to the RestTemplate mock not being applied.

- Mail service integration
  - MailService integration tests must be able to mock JavaMailSender and verify that MailService calls it as expected.
  - When the mail sender fails (e.g., throws MailSendException), MailService should propagate/handle the failure consistently with existing behavior.

If the mocking annotation is wrong or not supported under Boot 3.4, typical failures include the real bean being used instead of the mock (causing live HTTP calls or real mail sender initialization), or application context startup failures due to duplicate beans.

3) Reactive security test support (when applicable)

For reactive applications, ReactiveUserDetailsService (and, when generated, UserRepository) must be mockable for security tests. The generated test configuration should be compatible with Spring Boot 3.4 so that the reactive security context can initialize without failing and without relying on deprecated/removed annotations.

Expected behavior is that a freshly generated application targeting Spring Boot 3.4.0 can run its integration/security tests successfully without compilation errors and without context initialization errors related to test bean mocking/overriding or JWT test token creation.