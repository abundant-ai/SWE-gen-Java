#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/DualKotlinTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/DualKotlinTest.kt"

# Clean and rebuild codegen to ensure we use the current (buggy or fixed) code generator
./gradlew :kotlin:codegen:clean :kotlin:codegen:build -x test -x spotlessCheck -x spotlessApply --stacktrace

# Clean tests and run with KSP to use generated adapters (not reflection)
# This is critical - the bug is in the code generator, so we must use generated adapters!
./gradlew :kotlin:tests:clean --stacktrace
./gradlew :kotlin:tests:test -PkotlinTestMode=KSP --tests com.squareup.moshi.kotlin.DualKotlinTest --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
