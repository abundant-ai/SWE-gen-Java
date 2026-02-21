#!/bin/bash

cd /app/src

# Use Java 8 for tests (needed for Java 1.7 target compatibility)
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="${JAVA_HOME}/bin:${PATH}"

# Rebuild after applying fix.patch (for Oracle agent)
if [ -f /solution/fix.patch ]; then
  mvn install -DskipTests -Dcheckstyle.skip > /dev/null 2>&1 || true
fi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/reflect/src/main/test/java/com/squareup/moshi/kotlin/reflect"
cp "/tests/kotlin/reflect/src/main/test/java/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt" "kotlin/reflect/src/main/test/java/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt"

# The test file is in a non-standard Maven path (src/main/test/java).
# Copy it to src/test/java so the kotlin-maven-plugin's test-compile picks it up
# (kotlin-maven-plugin uses Maven's testCompileSourceRoots which defaults to src/test/java).
mkdir -p "kotlin/reflect/src/test/java/com/squareup/moshi/kotlin/reflect"
cp "kotlin/reflect/src/main/test/java/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt" "kotlin/reflect/src/test/java/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt"

# Run tests in the kotlin/reflect module (no KAPT, so generated adapter won't be found,
# which is exactly the scenario tested by fallsBackToReflectiveAdapterWithoutCodegen)
mvn test -pl kotlin/reflect -Dtest="KotlinJsonAdapterTest" -Dcheckstyle.skip -Dsurefire.timeout=30
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
