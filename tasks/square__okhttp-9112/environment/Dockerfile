FROM ubuntu:24.04

# Install base system packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 11 and 17 (as per CI config)
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set Java 17 as default
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/okhttp.git src && \
    cd src && \
    (git fetch --depth 1 origin a3d8839d1228bb133d72f9fffb9961ec67c6a4a1 || git fetch --depth 1 origin "+refs/pull/9112/head:refs/remotes/origin/pr/9112") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables as per CI config
ENV GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Download dependencies using Gradle wrapper
RUN ./gradlew dependencies --no-daemon || true

# Build the project
RUN ./gradlew compileKotlin compileTestKotlin --no-daemon

# Reset to ensure bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch
RUN ./gradlew compileKotlin compileTestKotlin --no-daemon

RUN rm -rf /app/src/.git

WORKDIR /app/src
