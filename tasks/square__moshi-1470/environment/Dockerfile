FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (required by the BASE state after bug.patch reverts to older dependencies)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/moshi.git src && \
    cd src && \
    (git fetch --depth 1 origin b78d9d41ba4fe909cb7e028b144e630123085686 || git fetch --depth 1 origin "+refs/pull/1470/head:refs/remotes/origin/pr/1470") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Gradle dependencies and compile the project (skip spotless due to Java 21 compatibility)
RUN ./gradlew build -x test -x spotlessCheck -x spotlessApply --stacktrace

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for compiled languages, skip spotless)
RUN ./gradlew build -x test -x spotlessCheck -x spotlessApply --stacktrace

RUN rm -rf /app/src/.git

WORKDIR /app/src
