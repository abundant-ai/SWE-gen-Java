#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-core/common/test"
cp "/tests/ktor-client/ktor-client-core/common/test/MultiPartFormDataContentTest.kt" "ktor-client/ktor-client-core/common/test/MultiPartFormDataContentTest.kt"
mkdir -p "ktor-server/ktor-server-jetty-jakarta/jvm/test/io/ktor/tests/server/jetty/jakarta"
cp "/tests/ktor-server/ktor-server-jetty-jakarta/jvm/test/io/ktor/tests/server/jetty/jakarta/JettyIdleTimeoutTest.kt" "ktor-server/ktor-server-jetty-jakarta/jvm/test/io/ktor/tests/server/jetty/jakarta/JettyIdleTimeoutTest.kt"
mkdir -p "ktor-server/ktor-server-jetty/jvm/test/io/ktor/tests/server/jetty"
cp "/tests/ktor-server/ktor-server-jetty/jvm/test/io/ktor/tests/server/jetty/JettyIdleTimeoutTest.kt" "ktor-server/ktor-server-jetty/jvm/test/io/ktor/tests/server/jetty/JettyIdleTimeoutTest.kt"
mkdir -p "ktor-server/ktor-server-test-base/jvm/src/io/ktor/server/test/base"
cp "/tests/ktor-server/ktor-server-test-base/jvm/src/io/ktor/server/test/base/HighLoadHttpGenerator.kt" "ktor-server/ktor-server-test-base/jvm/src/io/ktor/server/test/base/HighLoadHttpGenerator.kt"

FORM_DSL="ktor-client/ktor-client-core/common/src/io/ktor/client/request/forms/formDsl.kt"
BYTE_READ_PACKET="ktor-io/common/src/io/ktor/utils/io/core/ByteReadPacket.kt"
STREAMS="ktor-io/jvm/src/io/ktor/utils/io/streams/Streams.kt"
test_status=0

# Verify formDsl.kt uses value.peek() (fix), not value.copy() (bug)
if ! grep -q "PartData.BinaryItem({ value.peek() }" "$FORM_DSL"; then
    echo "FAIL: formDsl.kt should use value.peek() (fix), not value.copy() (bug)"
    test_status=1
fi

# Verify formDsl.kt imports kotlinx.io.Buffer (fix), not missing (bug)
if ! grep -q "import kotlinx.io.Buffer" "$FORM_DSL"; then
    echo "FAIL: formDsl.kt should import kotlinx.io.Buffer (fix)"
    test_status=1
fi

# Verify Source.copy() in ByteReadPacket.kt uses peek() (fix), not buffer.copy() (bug)
if ! grep -q "public fun Source.copy(): Source = peek()" "$BYTE_READ_PACKET"; then
    echo "FAIL: Source.copy() in ByteReadPacket.kt should return peek() (fix), not buffer.copy() (bug)"
    test_status=1
fi

# Verify Streams.kt uses transferTo (fix), not buffer.copyTo (bug)
if ! grep -q "packet.transferTo(this.asSink())" "$STREAMS"; then
    echo "FAIL: Streams.kt should use packet.transferTo(this.asSink()) (fix), not packet.buffer.copyTo(this) (bug)"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All multipart and Source.copy() fixes verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
