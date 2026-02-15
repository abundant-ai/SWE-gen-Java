#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/console/tasks"
cp "/tests/platform-tests/src/test/java/org/junit/platform/console/tasks/ColorPaletteTest.java" "platform-tests/src/test/java/org/junit/platform/console/tasks/ColorPaletteTest.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/console/tasks"
cp "/tests/platform-tests/src/test/java/org/junit/platform/console/tasks/FlatPrintingListenerTests.java" "platform-tests/src/test/java/org/junit/platform/console/tasks/FlatPrintingListenerTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/console/tasks"
cp "/tests/platform-tests/src/test/java/org/junit/platform/console/tasks/TreePrinterTests.java" "platform-tests/src/test/java/org/junit/platform/console/tasks/TreePrinterTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/console/tasks"
cp "/tests/platform-tests/src/test/java/org/junit/platform/console/tasks/VerboseTreeListenerTests.java" "platform-tests/src/test/java/org/junit/platform/console/tasks/VerboseTreeListenerTests.java"

# Run the specific test files using Gradle
./gradlew :platform-tests:test \
  --tests org.junit.platform.console.tasks.ColorPaletteTest \
  --tests org.junit.platform.console.tasks.FlatPrintingListenerTests \
  --tests org.junit.platform.console.tasks.TreePrinterTests \
  --tests org.junit.platform.console.tasks.VerboseTreeListenerTests \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
