#!/bin/bash

set -euo pipefail
cd /app/src

# Delete ZstdInterceptor.kt (created by bug.patch rename) before applying fix.patch
# This is necessary because patch doesn't handle git rename operations correctly
rm -f okhttp-zstd/src/main/kotlin/okhttp3/zstd/ZstdInterceptor.kt

patch -p1 < /solution/fix.patch
