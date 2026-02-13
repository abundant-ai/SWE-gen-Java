FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 8, 9, 11, 17, and 21 (okhttp build requires multiple toolchains)
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    openjdk-11-jdk \
    openjdk-17-jdk \
    openjdk-21-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Java 9 from OpenJDK archives
RUN wget -q https://download.java.net/java/GA/jdk9/9/binaries/openjdk-9_linux-x64_bin.tar.gz -O /tmp/jdk9.tar.gz && \
    mkdir -p /usr/lib/jvm/java-9-openjdk-amd64 && \
    tar -xzf /tmp/jdk9.tar.gz -C /usr/lib/jvm/java-9-openjdk-amd64 --strip-components=1 && \
    rm /tmp/jdk9.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/okhttp.git src && \
    cd src && \
    (git fetch --depth 1 origin 307b9fefeb7b04721ef9a6661c68499d8bb4b02a || git fetch --depth 1 origin "+refs/pull/9022/head:refs/remotes/origin/pr/9022") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Build the okhttp modules to compile dependencies and test classes
# Disable toolchain auto-provisioning to avoid Java 9 toolchain download failures
RUN ./gradlew :logging-interceptor:testClasses :okhttp:jvmTestClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java)
# Disable toolchain auto-provisioning to avoid Java 9 toolchain download failures
RUN ./gradlew :logging-interceptor:testClasses :okhttp:jvmTestClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

RUN rm -rf /app/src/.git

WORKDIR /app/src
