#!/bin/bash

cd /app/src

export CI=true

# For Oracle: apply fix.patch to restore the robovm-test module structure
# The bug.patch deleted the entire module, so we need to restore it
if [ -f "/solution/fix.patch" ]; then
  patch -p1 --forward --batch < /solution/fix.patch || true

  # fix.patch doesn't restore build.gradle changes, so we need to manually restore them
  # Add robovm version
  sed -i "/      'jaxb': '2.3.1',/a\\      'robovm': '2.3.9'," build.gradle

  # Add robovm dependencies
  sed -i "/      'jsoup': 'org.jsoup:jsoup:1.12.1',/a\\      'robovm': \"com.mobidevelop.robovm:robovm-rt:\${versions.robovm}\"," build.gradle

  # Add robovm gradle plugin
  sed -i "/    classpath 'gradle.plugin.com.github.sherter.google-java-format:google-java-format-gradle-plugin:0.9'/a\\    classpath \"com.mobidevelop.robovm:robovm-gradle-plugin:\${versions.robovm}\"" build.gradle
fi

# Copy HEAD test files from /tests (overwrites BASE state)
if [ -d "/tests" ]; then
  mkdir -p "retrofit/robovm-test/src/main/java/retrofit2"
  cp "/tests/retrofit/robovm-test/src/main/java/retrofit2/RoboVmPlatformTest.java" "retrofit/robovm-test/src/main/java/retrofit2/RoboVmPlatformTest.java" 2>/dev/null || true
fi

# For this task, we verify that the robovm-test module builds successfully and compiles
# (actually running RoboVM executables requires macOS and is not feasible in Docker)
# The key is that the module compiles and the Platform.java changes are correct
./gradlew :retrofit:robovm-test:classes --console=plain --no-daemon --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
