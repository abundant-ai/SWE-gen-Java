#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/MockitoTest.java" "src/test/java/org/mockito/MockitoTest.java"
mkdir -p "src/test/java/org/mockito/internal/configuration/plugins"
cp "/tests/java/org/mockito/internal/configuration/plugins/DefaultMockitoPluginsTest.java" "src/test/java/org/mockito/internal/configuration/plugins/DefaultMockitoPluginsTest.java"
mkdir -p "src/test/java/org/mockito/internal/runners"
cp "/tests/java/org/mockito/internal/runners/DefaultInternalRunnerTest.java" "src/test/java/org/mockito/internal/runners/DefaultInternalRunnerTest.java"
mkdir -p "src/test/java/org/mockitousage/annotation"
cp "/tests/java/org/mockitousage/annotation/SpyAnnotationTest.java" "src/test/java/org/mockitousage/annotation/SpyAnnotationTest.java"
mkdir -p "src/test/java/org/mockitousage/configuration"
cp "/tests/java/org/mockitousage/configuration/ClassCacheVersusClassReloadingTest.java" "src/test/java/org/mockitousage/configuration/ClassCacheVersusClassReloadingTest.java"
mkdir -p "src/test/java/org/mockitousage/misuse"
cp "/tests/java/org/mockitousage/misuse/InvalidUsageTest.java" "src/test/java/org/mockitousage/misuse/InvalidUsageTest.java"
mkdir -p "subprojects/module-test/src/test/java/org/mockito/moduletest"
cp "/tests/subprojects/module-test/src/test/java/org/mockito/moduletest/ModuleAccessTest.java" "subprojects/module-test/src/test/java/org/mockito/moduletest/ModuleAccessTest.java"
mkdir -p "subprojects/module-test/src/test/java/org/mockito/moduletest"
cp "/tests/subprojects/module-test/src/test/java/org/mockito/moduletest/ReplicatingClassLoader.java" "subprojects/module-test/src/test/java/org/mockito/moduletest/ReplicatingClassLoader.java"
mkdir -p "subprojects/osgi-test/src/test/java/org/mockito/osgitest"
cp "/tests/subprojects/osgi-test/src/test/java/org/mockito/osgitest/OsgiTest.java" "subprojects/osgi-test/src/test/java/org/mockito/osgitest/OsgiTest.java"
mkdir -p "subprojects/osgi-test/src/testBundle/java/org/mockito/osgitest/testbundle"
cp "/tests/subprojects/osgi-test/src/testBundle/java/org/mockito/osgitest/testbundle/MockNonPublicClassTest.java" "subprojects/osgi-test/src/testBundle/java/org/mockito/osgitest/testbundle/MockNonPublicClassTest.java"
mkdir -p "subprojects/programmatic-test/src/test/java/org/mockitousage/annotation"
cp "/tests/subprojects/programmatic-test/src/test/java/org/mockitousage/annotation/ProgrammaticMockMakerAnnotationTest.java" "subprojects/programmatic-test/src/test/java/org/mockitousage/annotation/ProgrammaticMockMakerAnnotationTest.java"

# Run the specific tests for this PR
./gradlew :test \
  --tests org.mockito.MockitoTest \
  --tests org.mockito.internal.configuration.plugins.DefaultMockitoPluginsTest \
  --tests org.mockito.internal.runners.DefaultInternalRunnerTest \
  --tests org.mockitousage.annotation.SpyAnnotationTest \
  --tests org.mockitousage.configuration.ClassCacheVersusClassReloadingTest \
  --tests org.mockitousage.misuse.InvalidUsageTest \
  --no-daemon --rerun-tasks

main_test_status=$?

# Run subproject tests
./gradlew :module-test:test \
  --tests org.mockito.moduletest.ModuleAccessTest \
  --no-daemon --rerun-tasks
module_test_status=$?

./gradlew :osgi-test:test \
  --tests org.mockito.osgitest.OsgiTest \
  --no-daemon --rerun-tasks
osgi_test_status=$?

./gradlew :programmatic-test:test \
  --tests org.mockitousage.annotation.ProgrammaticMockMakerAnnotationTest \
  --no-daemon --rerun-tasks
programmatic_test_status=$?

# Overall test status (fail if any subproject fails)
if [ $main_test_status -eq 0 ] && [ $module_test_status -eq 0 ] && [ $osgi_test_status -eq 0 ] && [ $programmatic_test_status -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
