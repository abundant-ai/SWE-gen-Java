#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-platform-console/src/main/java/org/junit/platform/console/tasks"
cp "/tests/junit-platform-console/src/main/java/org/junit/platform/console/tasks/TestFeedPrintingListener.java" "junit-platform-console/src/main/java/org/junit/platform/console/tasks/TestFeedPrintingListener.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/console/tasks"
cp "/tests/platform-tests/src/test/java/org/junit/platform/console/tasks/TestFeedPrintingListenerTests.java" "platform-tests/src/test/java/org/junit/platform/console/tasks/TestFeedPrintingListenerTests.java"
mkdir -p "platform-tests/src/test/resources/console/details/basic"
cp "/tests/platform-tests/src/test/resources/console/details/basic/Basic-changeDisplayName-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/basic/Basic-changeDisplayName-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/basic"
cp "/tests/platform-tests/src/test/resources/console/details/basic/Basic-changeDisplayName-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/basic/Basic-changeDisplayName-testfeed-unicode.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/basic"
cp "/tests/platform-tests/src/test/resources/console/details/basic/Basic-empty-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/basic/Basic-empty-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/basic"
cp "/tests/platform-tests/src/test/resources/console/details/basic/Basic-empty-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/basic/Basic-empty-testfeed-unicode.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/fail"
cp "/tests/platform-tests/src/test/resources/console/details/fail/Fail-failWithMultiLineMessage-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/fail/Fail-failWithMultiLineMessage-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/fail"
cp "/tests/platform-tests/src/test/resources/console/details/fail/Fail-failWithMultiLineMessage-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/fail/Fail-failWithMultiLineMessage-testfeed-unicode.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/fail"
cp "/tests/platform-tests/src/test/resources/console/details/fail/Fail-failWithSingleLineMessage-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/fail/Fail-failWithSingleLineMessage-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/fail"
cp "/tests/platform-tests/src/test/resources/console/details/fail/Fail-failWithSingleLineMessage-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/fail/Fail-failWithSingleLineMessage-testfeed-unicode.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/report"
cp "/tests/platform-tests/src/test/resources/console/details/report/Report-reportMultiEntriesWithMultiMappings-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/report/Report-reportMultiEntriesWithMultiMappings-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/report"
cp "/tests/platform-tests/src/test/resources/console/details/report/Report-reportMultiEntriesWithMultiMappings-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/report/Report-reportMultiEntriesWithMultiMappings-testfeed-unicode.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/report"
cp "/tests/platform-tests/src/test/resources/console/details/report/Report-reportMultiEntriesWithSingleMapping-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/report/Report-reportMultiEntriesWithSingleMapping-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/report"
cp "/tests/platform-tests/src/test/resources/console/details/report/Report-reportMultiEntriesWithSingleMapping-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/report/Report-reportMultiEntriesWithSingleMapping-testfeed-unicode.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/report"
cp "/tests/platform-tests/src/test/resources/console/details/report/Report-reportMultipleMessages-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/report/Report-reportMultipleMessages-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/report"
cp "/tests/platform-tests/src/test/resources/console/details/report/Report-reportMultipleMessages-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/report/Report-reportMultipleMessages-testfeed-unicode.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/report"
cp "/tests/platform-tests/src/test/resources/console/details/report/Report-reportSingleEntryWithSingleMapping-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/report/Report-reportSingleEntryWithSingleMapping-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/report"
cp "/tests/platform-tests/src/test/resources/console/details/report/Report-reportSingleEntryWithSingleMapping-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/report/Report-reportSingleEntryWithSingleMapping-testfeed-unicode.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/report"
cp "/tests/platform-tests/src/test/resources/console/details/report/Report-reportSingleMessage-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/report/Report-reportSingleMessage-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/report"
cp "/tests/platform-tests/src/test/resources/console/details/report/Report-reportSingleMessage-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/report/Report-reportSingleMessage-testfeed-unicode.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/skip"
cp "/tests/platform-tests/src/test/resources/console/details/skip/Skip-skipWithMultiLineMessage-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/skip/Skip-skipWithMultiLineMessage-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/skip"
cp "/tests/platform-tests/src/test/resources/console/details/skip/Skip-skipWithMultiLineMessage-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/skip/Skip-skipWithMultiLineMessage-testfeed-unicode.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/skip"
cp "/tests/platform-tests/src/test/resources/console/details/skip/Skip-skipWithSingleLineReason-testfeed-ascii.out.txt" "platform-tests/src/test/resources/console/details/skip/Skip-skipWithSingleLineReason-testfeed-ascii.out.txt"
mkdir -p "platform-tests/src/test/resources/console/details/skip"
cp "/tests/platform-tests/src/test/resources/console/details/skip/Skip-skipWithSingleLineReason-testfeed-unicode.out.txt" "platform-tests/src/test/resources/console/details/skip/Skip-skipWithSingleLineReason-testfeed-unicode.out.txt"
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/StandaloneTests.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/StandaloneTests.java"

# Rebuild test classes to pick up the changes
./gradlew :platform-tests:testClasses :platform-tooling-support-tests:testClasses --no-daemon --no-configuration-cache

# Run the specific test classes from this PR
./gradlew :platform-tests:test --tests org.junit.platform.console.tasks.TestFeedPrintingListenerTests \
    :platform-tooling-support-tests:test --tests platform.tooling.support.tests.StandaloneTests \
    --no-daemon --no-configuration-cache 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
