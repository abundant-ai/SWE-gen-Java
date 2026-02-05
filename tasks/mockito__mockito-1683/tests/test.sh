#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockitousage/internal/debugging"
cp "/tests/java/org/mockitousage/internal/debugging/LocationImplTest.java" "src/test/java/org/mockitousage/internal/debugging/LocationImplTest.java"
mkdir -p "subprojects/memory-test/src/test/java/org/mockito/memorytest"
cp "/tests/subprojects/memory-test/src/test/java/org/mockito/memorytest/ShouldNotStarveMemoryOnLargeStackTraceInvocationsTest.java" "subprojects/memory-test/src/test/java/org/mockito/memorytest/ShouldNotStarveMemoryOnLargeStackTraceInvocationsTest.java"

# Fix jcenter issue (JCenter is shut down) and comment out shipkit/build-scan plugins (requires unavailable dependencies)
# Also disable kotlinReleaseCoroutinesTest subproject (requires unavailable Kotlin 1.3.0-rc-57 from defunct bintray)
sed -i 's|jcenter()|mavenCentral()|g' build.gradle
test -f subprojects/osgi-test/osgi-test-bundles.gradle && sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle || true
sed -i '/classpath.*shipkit/s|^|//|' build.gradle
sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle
sed -i '/id.*com.gradle.build-scan/s|^|//|' build.gradle
sed -i '/buildScan {/,/^}/s|^|//|' build.gradle
sed -i '/bintrayUpload/s|^|//|' build.gradle
sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle
sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle
sed -i '/^description = /i version = "3.0.0"' build.gradle
test -f settings.gradle.kts && sed -i '/kotlinReleaseCoroutinesTest/s|^|//|' settings.gradle.kts || true
test -f settings.gradle && sed -i "/include 'kotlinReleaseCoroutinesTest'/s|^|//|" settings.gradle || true

# Run the specific test files for this PR (main project and memory-test subproject)
./gradlew :test --tests org.mockitousage.internal.debugging.LocationImplTest \
  :memory-test:test --tests org.mockito.memorytest.ShouldNotStarveMemoryOnLargeStackTraceInvocationsTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
