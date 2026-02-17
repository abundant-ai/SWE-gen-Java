#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-http/ktor-http-cio/jvm/test/io/ktor/tests/http/cio"
cp "/tests/ktor-http/ktor-http-cio/jvm/test/io/ktor/tests/http/cio/ChunkedTest.kt" "ktor-http/ktor-http-cio/jvm/test/io/ktor/tests/http/cio/ChunkedTest.kt"

LINE_ENDING_MODE="ktor-io/common/src/io/ktor/utils/io/LineEndingMode.kt"
HTTP_PARSER="ktor-http/ktor-http-cio/common/src/io/ktor/http/cio/HttpParser.kt"
CHUNKED_ENCODING="ktor-http/ktor-http-cio/common/src/io/ktor/http/cio/ChunkedTransferEncoding.kt"
BYTE_READ_OPS="ktor-io/common/src/io/ktor/utils/io/ByteReadChannelOperations.kt"
test_status=0

# Verify LineEndingMode.kt exists (fix), was removed in bug
if [ ! -f "$LINE_ENDING_MODE" ]; then
    echo "FAIL: LineEndingMode.kt does not exist (bug: line ending validation missing)"
    test_status=1
fi

# Verify LineEndingMode class defines CRLF, LF, CR modes (fix)
if ! grep -q "val CRLF" "$LINE_ENDING_MODE" 2>/dev/null; then
    echo "FAIL: LineEndingMode.kt should define CRLF mode (fix)"
    test_status=1
fi

# Verify httpLineEndings is defined in HttpParser (fix)
if ! grep -q "httpLineEndings" "$HTTP_PARSER"; then
    echo "FAIL: HttpParser.kt should define httpLineEndings (fix)"
    test_status=1
fi

# Verify httpLineEndings uses CRLF + LF (not bare CR)
if ! grep -q "LineEndingMode.CRLF + LineEndingMode.LF" "$HTTP_PARSER"; then
    echo "FAIL: httpLineEndings should be CRLF + LF (fix)"
    test_status=1
fi

# Verify readUTF8LineTo in ChunkedTransferEncoding passes httpLineEndings (fix)
if ! grep -q "readUTF8LineTo.*httpLineEndings" "$CHUNKED_ENCODING"; then
    echo "FAIL: ChunkedTransferEncoding.kt should pass httpLineEndings to readUTF8LineTo (fix)"
    test_status=1
fi

# Verify readUTF8LineTo in ByteReadChannelOperations has lineEnding parameter (fix)
if ! grep -q "lineEnding: LineEndingMode" "$BYTE_READ_OPS"; then
    echo "FAIL: ByteReadChannelOperations.kt should have lineEnding parameter in readUTF8LineTo (fix)"
    test_status=1
fi

# Verify checkLineEndingAllowed is implemented (validates line endings)
if ! grep -q "checkLineEndingAllowed" "$BYTE_READ_OPS"; then
    echo "FAIL: ByteReadChannelOperations.kt should implement checkLineEndingAllowed (fix)"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All line ending validation fix verifications passed"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
