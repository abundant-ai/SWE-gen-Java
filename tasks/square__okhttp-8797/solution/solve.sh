#!/bin/bash

set -euo pipefail
cd /app/src

# Apply text portions of fix.patch (binary files will fail, that's OK)
patch -p1 --force --forward < /solution/fix.patch || true

# Remove the .gz file from buggy state
rm -f okhttp/src/jvmMain/resources/okhttp3/internal/publicsuffix/PublicSuffixDatabase.gz

# Copy the .list file for fixed state
cp /resources/PublicSuffixDatabase.list okhttp/src/jvmMain/resources/okhttp3/internal/publicsuffix/PublicSuffixDatabase.list
