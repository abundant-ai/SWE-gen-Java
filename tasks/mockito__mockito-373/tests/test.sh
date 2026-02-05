#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal"
cp "/tests/java/org/mockito/internal/AllInvocationsFinderTest.java" "src/test/java/org/mockito/internal/AllInvocationsFinderTest.java"
mkdir -p "src/test/java/org/mockito/internal/invocation"
cp "/tests/java/org/mockito/internal/invocation/InvocationImplTest.java" "src/test/java/org/mockito/internal/invocation/InvocationImplTest.java"
mkdir -p "src/test/java/org/mockitousage"
cp "/tests/java/org/mockitousage/PlaygroundWithDemoOfUnclonedParametersProblemTest.java" "src/test/java/org/mockitousage/PlaygroundWithDemoOfUnclonedParametersProblemTest.java"
mkdir -p "src/test/java/org/mockitousage/customization"
cp "/tests/java/org/mockitousage/customization/BDDMockitoTest.java" "src/test/java/org/mockitousage/customization/BDDMockitoTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StubbingWithCustomAnswerTest.java" "src/test/java/org/mockitousage/stubbing/StubbingWithCustomAnswerTest.java"

# Fix kotlinTest dependency on kotlinx-coroutines-core (0.14 no longer available, use 0.19)
test -f subprojects/kotlinTest/build.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/build.gradle || true
test -f subprojects/kotlinTest/kotlinTest.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/kotlinTest.gradle || true

# Disable buildSrc tests by renaming the test directory temporarily
test -d buildSrc/src/test && mv buildSrc/src/test buildSrc/src/test.disabled || true

# Reapply build fixes
sed -i 's|jcenter()|mavenCentral()|g' build.gradle
(test -f subprojects/osgi-test/osgi-test-bundles.gradle && sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle || true)
sed -i '/classpath.*mockito-release-tools/s|^|//|' build.gradle
sed -i '/classpath.*bintray/s|^|//|' build.gradle
sed -i '/classpath.*http-builder/s|^|//|' build.gradle
sed -i '/classpath.*shipkit/s|^|//|' build.gradle
sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle
sed -i '/id.*com.gradle.build-scan/s|^|//|' build.gradle
sed -i '/id.*me.champeau.buildscan-recipes/s|^|//|' build.gradle
sed -i '/apply plugin.*me.champeau.buildscan-recipes/s|^|//|' build.gradle
sed -i '/buildScan {/,/^}/s|^|//|' build.gradle
sed -i '/release\.gradle/s|^|//|' build.gradle
sed -i '/release\.mustRunAfter/s|^|//|' build.gradle
sed -i '/publishable-java-library\.gradle/s|^|//|' build.gradle
sed -i '/bintrayUpload/s|^|//|' build.gradle
sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle
grep -q '^version = ' build.gradle || sed -i '/^description = /i version = "3.0.0"' build.gradle
sed -i '/classpath.*errorprone/s|^|//|' build.gradle
sed -i '/apply from.*errorprone/s|^|//|' build.gradle
sed -i '/apply plugin.*errorprone/s|^|//|' build.gradle
sed -i '/errorprone libraries\.errorprone/s|^|//|' build.gradle
sed -i '/coverage\.gradle/s|^|//|' build.gradle
(test -f subprojects/extTest/extTest.gradle && sed -i '/dependsOn.*publishToMavenLocal/s|^|//|' subprojects/extTest/extTest.gradle || true)
(test -f settings.gradle && sed -i "s/include 'errorprone'/\\/\\/ include 'errorprone'/" settings.gradle || true)

# Disable errorprone and kotlinReleaseCoroutinesTest subprojects again
test -d subprojects/errorprone && mv subprojects/errorprone subprojects/errorprone.disabled || true
test -d subprojects/kotlinReleaseCoroutinesTest && mv subprojects/kotlinReleaseCoroutinesTest subprojects/kotlinReleaseCoroutinesTest.disabled || true

# Recompile tests after copying HEAD test files
./gradlew compileTestJava --no-daemon
if [ $? -ne 0 ]; then
  echo "Test compilation failed"
  test_status=1
else
  # Run the specific test files for this PR
  test_status=0
  for test_class in \
    "org.mockito.internal.AllInvocationsFinderTest" \
    "org.mockito.internal.invocation.InvocationImplTest" \
    "org.mockitousage.PlaygroundWithDemoOfUnclonedParametersProblemTest" \
    "org.mockitousage.customization.BDDMockitoTest" \
    "org.mockitousage.stubbing.StubbingWithCustomAnswerTest"
  do
    ./gradlew :test --tests "$test_class" --no-daemon
    if [ $? -ne 0 ]; then
      test_status=1
      break
    fi
  done
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
