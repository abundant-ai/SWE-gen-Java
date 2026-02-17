#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "kotlin/tests"
cp "/tests/kotlin/tests/build.gradle.kts" "kotlin/tests/build.gradle.kts"
mkdir -p "kotlin/tests/codegen-only"
cp "/tests/kotlin/tests/codegen-only/build.gradle.kts" "kotlin/tests/codegen-only/build.gradle.kts"
mkdir -p "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/CompileOnlyTests.kt" "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/CompileOnlyTests.kt"
mkdir -p "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/ComplexGenericsInheritanceTest.kt" "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/ComplexGenericsInheritanceTest.kt"
mkdir -p "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/DefaultConstructorTest.kt" "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/DefaultConstructorTest.kt"
mkdir -p "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/GeneratedAdaptersTest.kt" "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/GeneratedAdaptersTest.kt"
mkdir -p "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/GeneratedAdaptersTest_CustomGeneratedClassJsonAdapter.kt" "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/GeneratedAdaptersTest_CustomGeneratedClassJsonAdapter.kt"
mkdir -p "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/LooksLikeAClass"
cp "/tests/kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/LooksLikeAClass/ClassInPackageThatLooksLikeAClass.kt" "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/LooksLikeAClass/ClassInPackageThatLooksLikeAClass.kt"
mkdir -p "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/MixingReflectAndCodeGen.kt" "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/MixingReflectAndCodeGen.kt"
mkdir -p "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/MoshiKspTest.kt" "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/MoshiKspTest.kt"
mkdir -p "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen"
cp "/tests/kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/MultipleMasksTest.kt" "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/MultipleMasksTest.kt"
mkdir -p "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/annotation"
cp "/tests/kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/annotation/UppercaseInAnnotationPackage.kt" "kotlin/tests/codegen-only/src/test/kotlin/com/squareup/moshi/kotlin/codegen/annotation/UppercaseInAnnotationPackage.kt"
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/DualKotlinTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/DualKotlinTest.kt"
mkdir -p "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect"
cp "/tests/kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt" "kotlin/tests/src/test/kotlin/com/squareup/moshi/kotlin/reflect/KotlinJsonAdapterTest.kt"

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
