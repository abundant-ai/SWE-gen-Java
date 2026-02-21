#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "moshi/src/test/java/com/squareup/moshi"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonCodecFactory.java" "moshi/src/test/java/com/squareup/moshi/JsonCodecFactory.java"
cp "/tests/moshi/src/test/java/com/squareup/moshi/JsonReaderTest.java" "moshi/src/test/java/com/squareup/moshi/JsonReaderTest.java"

# Rebuild main sources after applying fix.patch (for Oracle agent)
# fix.patch downgrades assertj to 1.7.0 but some test files use assertj 3.x APIs
# so we keep assertj at 3.11.1 for compilation compatibility
if [ -f /solution/fix.patch ]; then
  mvn install -Dmaven.test.skip=true -Dcheckstyle.skip > /dev/null 2>&1 || true
fi

# Run the JsonReaderTest in the moshi module
# Override assertj.version to 3.11.1 to match other test files in the module
mvn test -pl moshi -Dtest="JsonReaderTest" -Dcheckstyle.skip -Dassertj.version=3.11.1 -Dsurefire.timeout=30
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
