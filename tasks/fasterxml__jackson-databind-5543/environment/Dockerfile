FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 and Maven
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV CI=true

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin bc05f195a02cce33a72d00776000b958cb955ec9 || git fetch --depth 1 origin "+refs/pull/5543/head:refs/remotes/origin/pr/5543") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Pre-download Maven dependencies to speed up test runs
RUN mvn -B -ntp dependency:resolve dependency:resolve-plugins -q || true

# Build project (compile sources and tests) to cache compiled classes
RUN mvn -B -ntp compile test-compile -q || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java compiled classes must reflect patched source)
RUN mvn -B -ntp compile test-compile -q || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
