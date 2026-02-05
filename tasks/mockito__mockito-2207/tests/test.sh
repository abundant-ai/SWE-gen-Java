#!/bin/bash

cd /app/src

# Fix jcenter issue (JCenter is shut down)
sed -i 's/jcenter()/mavenCentral()/g' build.gradle
sed -i '/gradle-bintray-plugin/d' build.gradle
sed -i '/apply plugin.*bintray/d' gradle/java-publication.gradle
sed -i '/^bintray {/,/^}/d' gradle/java-publication.gradle
sed -i '/bintrayPublish/d' gradle/shipkit.gradle

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/groovyTest/src/test/groovy/org/mockito/groovy"
cp "/tests/subprojects/groovyTest/src/test/groovy/org/mockito/groovy/GroovyMockitoTest.groovy" "subprojects/groovyTest/src/test/groovy/org/mockito/groovy/GroovyMockitoTest.groovy"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR
./gradlew :groovyTest:test --tests org.mockito.groovy.GroovyMockitoTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
