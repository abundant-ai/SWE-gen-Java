#!/bin/bash

cd /app/src

# Check that @Nullable is properly applied to the getter methods in Test.java.
# The fix adds @Nullable before getMinHeapSize(), getDefaultCharacterEncoding(), and getMaxHeapSize().
# The buggy version removes those @Nullable annotations.

TEST_FILE="platforms/jvm/testing-jvm/src/main/java/org/gradle/api/tasks/testing/Test.java"

check_nullable_on_method() {
    local method_name="$1"
    # Check if @Nullable appears within 2 lines before the method declaration
    grep -B2 "public String ${method_name}()" "${TEST_FILE}" | grep -q "@Nullable"
}

if check_nullable_on_method "getMinHeapSize" && \
   check_nullable_on_method "getMaxHeapSize" && \
   check_nullable_on_method "getDefaultCharacterEncoding"; then
    echo "All @Nullable annotations are present on getter methods."
    echo 1 > /logs/verifier/reward.txt
    exit 0
else
    echo "ERROR: Missing @Nullable annotation(s) on getter method(s) in Test.java" >&2
    echo "Expected @Nullable on: getMinHeapSize(), getMaxHeapSize(), getDefaultCharacterEncoding()" >&2
    echo 0 > /logs/verifier/reward.txt
    exit 1
fi
