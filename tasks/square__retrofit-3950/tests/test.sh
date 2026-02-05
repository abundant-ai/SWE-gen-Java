#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# fix.patch doesn't restore the plugin in root build.gradle, so add it manually if missing
if ! grep -q "alias(libs.plugins.kotlin.serialization)" build.gradle; then
  sed -i '/alias(libs.plugins.kotlin.jvm) apply false/a\  alias(libs.plugins.kotlin.serialization) apply false' build.gradle
fi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization"
cp "/tests/retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryBytesTest.kt" "retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryBytesTest.kt"
cp "/tests/retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryStringTest.kt" "retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryStringTest.kt"
cp "/tests/retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualListTest.kt" "retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualListTest.kt"
cp "/tests/retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualTest.kt" "retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualTest.kt"

# Touch the files to update timestamps so Gradle recognizes the changes
touch "retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryBytesTest.kt"
touch "retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryStringTest.kt"
touch "retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualListTest.kt"
touch "retrofit-converters/kotlinx-serialization/src/test/java/com/jakewharton/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualTest.kt"

# Clean and rebuild the kotlinx-serialization module (since fix.patch restored it)
rm -rf retrofit-converters/kotlinx-serialization/build/
./gradlew :retrofit-converters:kotlinx-serialization:build --no-daemon -x test || true

# Run only the specific test classes
./gradlew :retrofit-converters:kotlinx-serialization:test --tests "com.jakewharton.retrofit2.converter.kotlinx.serialization.KotlinSerializationConverterFactoryBytesTest" --tests "com.jakewharton.retrofit2.converter.kotlinx.serialization.KotlinSerializationConverterFactoryStringTest" --tests "com.jakewharton.retrofit2.converter.kotlinx.serialization.KotlinxSerializationConverterFactoryContextualListTest" --tests "com.jakewharton.retrofit2.converter.kotlinx.serialization.KotlinxSerializationConverterFactoryContextualTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
