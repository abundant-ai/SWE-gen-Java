FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install both Java 11 and Java 17
# BASE state (after bug.patch) needs Java 11 to compile to old targets (1.6/1.7/1.8)
# FIXED state needs Java 17 for records-tests
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Use Java 11 by default for BASE state
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/moshi.git src && \
    cd src && \
    (git fetch --depth 1 origin f3c91e006d6cbc3efa37801e8621e8899279c139 || git fetch --depth 1 origin "+refs/pull/1380/head:refs/remotes/origin/pr/1380") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Gradle dependencies and compile the project (skip spotless due to Java 21 compatibility)
RUN ./gradlew build -x test -x spotlessCheck -x spotlessApply --stacktrace

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for compiled languages, skip spotless)
RUN ./gradlew build -x test -x spotlessCheck -x spotlessApply --stacktrace

RUN rm -rf /app/src/.git

WORKDIR /app/src
