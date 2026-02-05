#!/bin/bash

cd /app/src

# Apply the full fix.patch to get to HEAD state (fixes the bug)
patch -p1 < /solution/fix.patch || true

# Fix jcenter issue (JCenter is shut down) and comment out shipkit plugin (requires unavailable dependencies)
# Also disable kotlinReleaseCoroutinesTest subproject (requires unavailable Kotlin 1.3.0-rc-57 from defunct bintray)
# Update bnd plugin to newer version for better Gradle 5.3 compatibility
sed -i 's|biz.aQute.bnd:biz.aQute.bnd.gradle:4.3.1|biz.aQute.bnd:biz.aQute.bnd.gradle:5.1.2|g' gradle/dependencies.gradle
sed -i 's|jcenter()|mavenCentral()|g' build.gradle
sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle
sed -i '/classpath.*shipkit/s|^|//|' build.gradle
sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle
sed -i '/bintrayUpload/s|^|//|' build.gradle
sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle
sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle
sed -i '/^description = /i version = "3.0.0"' build.gradle
sed -i '/kotlinReleaseCoroutinesTest/s|^|//|' settings.gradle.kts

# Run the specific tests for this PR
./gradlew :osgi-test:test --tests org.mockito.osgitest.OsgiTest \
  --tests org.mockito.osgitest.testbundle.MockClassInOtherBundleTest \
  --tests org.mockito.osgitest.testbundle.MockNonPublicClassFailsTest \
  --tests org.mockito.osgitest.testbundle.SimpleMockTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
