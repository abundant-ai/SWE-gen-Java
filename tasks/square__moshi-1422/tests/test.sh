#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/codegen/src/test/java/com/tschuchort/compiletesting"
cp "/tests/kotlin/codegen/src/test/java/com/tschuchort/compiletesting/Ksp.kt" "kotlin/codegen/src/test/java/com/tschuchort/compiletesting/Ksp.kt"
mkdir -p "kotlin/tests/extra-moshi-test-module/src/main/kotlin/com/squareup/moshi/kotlin/codegen/test/extra"
cp "/tests/kotlin/tests/extra-moshi-test-module/src/main/kotlin/com/squareup/moshi/kotlin/codegen/test/extra/AbstractClassInModuleA.kt" "kotlin/tests/extra-moshi-test-module/src/main/kotlin/com/squareup/moshi/kotlin/codegen/test/extra/AbstractClassInModuleA.kt"

# Clean and rebuild codegen to ensure we use the current (buggy or fixed) code generator
./gradlew :kotlin:codegen:clean :kotlin:codegen:build -x test -x spotlessCheck -x spotlessApply --stacktrace

# Clean tests and run with KSP to use generated adapters (not reflection)
# This is critical - the bug is in the code generator, so we must use generated adapters!
./gradlew :kotlin:tests:codegen-only:clean --stacktrace
./gradlew :kotlin:tests:codegen-only:test -PkotlinTestMode=KSP --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
