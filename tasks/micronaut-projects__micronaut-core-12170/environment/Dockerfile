FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 21 (as used in CI)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/micronaut-projects/micronaut-core.git src && \
    cd src && \
    (git fetch --depth 1 origin 07124a2748c8efa6ae5deb6e4883612b28195f52 || git fetch --depth 1 origin "+refs/pull/12170/head:refs/remotes/origin/pr/12170") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for build
ENV TESTCONTAINERS_RYUK_DISABLED=true
ENV CI=true

# Download dependencies and compile the project
RUN ./gradlew compileGroovy compileTestGroovy --no-daemon --console=plain

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is a compiled language)
RUN ./gradlew compileGroovy compileTestGroovy --no-daemon --console=plain

RUN rm -rf /app/src/.git

WORKDIR /app/src
