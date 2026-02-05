#!/bin/bash

cd /app/src

# Fix jcenter issue (JCenter is shut down) and comment out shipkit plugin (requires unavailable dependencies)
sed -i 's|jcenter()|mavenCentral()|g' build.gradle
sed -i '/classpath.*shipkit/s|^|//|' build.gradle
sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle
sed -i '/bintrayUpload/s|^|//|' build.gradle
sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle
sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle
sed -i '/^description = /i version = "3.0.0"' build.gradle

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/extTest/src/test/java/org/mockitousage/plugins/resolver"
cp "/tests/subprojects/extTest/src/test/java/org/mockitousage/plugins/resolver/MockResolverTest.java" "subprojects/extTest/src/test/java/org/mockitousage/plugins/resolver/MockResolverTest.java"
mkdir -p "subprojects/extTest/src/test/java/org/mockitousage/plugins/resolver"
cp "/tests/subprojects/extTest/src/test/java/org/mockitousage/plugins/resolver/MyMockResolver.java" "subprojects/extTest/src/test/java/org/mockitousage/plugins/resolver/MyMockResolver.java"
mkdir -p "subprojects/extTest/src/test/java/org/mockitousage/plugins/switcher"
cp "/tests/subprojects/extTest/src/test/java/org/mockitousage/plugins/switcher/PluginSwitchTest.java" "subprojects/extTest/src/test/java/org/mockitousage/plugins/switcher/PluginSwitchTest.java"
mkdir -p "subprojects/extTest/src/test/resources/mockito-extensions"
cp "/tests/subprojects/extTest/src/test/resources/mockito-extensions/org.mockito.plugins.MockResolver" "subprojects/extTest/src/test/resources/mockito-extensions/org.mockito.plugins.MockResolver"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR (MockResolverTest and PluginSwitchTest in extTest)
./gradlew :extTest:test --tests org.mockitousage.plugins.resolver.MockResolverTest \
  --tests org.mockitousage.plugins.switcher.PluginSwitchTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
