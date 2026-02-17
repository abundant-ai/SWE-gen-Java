FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (used by Gradle build)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/gradle/gradle.git src && \
    cd src && \
    (git fetch --depth 1 origin 133e976439cdf532e5ddf32e8dc28c06d7d9c068 || git fetch --depth 1 origin "+refs/pull/34976/head:refs/remotes/origin/pr/34976") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Build the launcher subproject to compile and prepare test dependencies
RUN ./gradlew :launcher:compileJava :launcher:compileTestGroovy --no-daemon

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java/Groovy code needs recompilation)
RUN ./gradlew :launcher:compileJava :launcher:compileTestGroovy --no-daemon

RUN rm -rf /app/src/.git

WORKDIR /app/src
