#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/CallTest.java" "retrofit/src/test/java/retrofit/CallTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# Rebuild OkHttp 2.5.0-SNAPSHOT in case it's not in the local Maven repo
cd /app/okhttp && mvn clean install -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true
cd /app/src

# Recreate stub MockWebServerRule in case it was removed
mkdir -p retrofit/src/test/java/com/squareup/okhttp/mockwebserver/rule
cat > retrofit/src/test/java/com/squareup/okhttp/mockwebserver/rule/MockWebServerRule.java << 'EOF'
package com.squareup.okhttp.mockwebserver.rule;

import com.squareup.okhttp.HttpUrl;
import com.squareup.okhttp.mockwebserver.MockResponse;
import com.squareup.okhttp.mockwebserver.MockWebServer;
import com.squareup.okhttp.mockwebserver.RecordedRequest;
import org.junit.rules.TestRule;
import org.junit.runner.Description;
import org.junit.runners.model.Statement;

public final class MockWebServerRule implements TestRule {
  private final MockWebServer server = new MockWebServer();

  public HttpUrl url(String path) {
    return server.url(path);
  }

  public void enqueue(MockResponse response) {
    server.enqueue(response);
  }

  public RecordedRequest takeRequest() throws InterruptedException {
    return server.takeRequest();
  }

  @Override public Statement apply(final Statement base, Description description) {
    return new Statement() {
      @Override public void evaluate() throws Throwable {
        server.start();
        try {
          base.evaluate();
        } finally {
          server.shutdown();
        }
      }
    };
  }
}
EOF

# First, recompile and install only the retrofit module (not all submodules)
# This avoids compilation errors in other modules like adapter-rxjava
mvn clean install -U -pl retrofit -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true

# Run the specific test class for this PR
# CallTest is in the retrofit module (root)
mvn test -pl retrofit -Dtest=CallTest -Dmaven.javadoc.skip=true
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
