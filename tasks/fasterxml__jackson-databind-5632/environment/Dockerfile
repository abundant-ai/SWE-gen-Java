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

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin f5d61badd6691e7d6d62a41f4869e7d9df10e58b || git fetch --depth 1 origin "+refs/pull/5632/head:refs/remotes/origin/pr/5632") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true

# Pre-download Maven dependencies to speed up test runs
RUN mvn -B -ff -ntp dependency:resolve dependency:resolve-plugins -DincludeScope=test || true

# Build the project (compile sources and tests, skip running tests)
RUN mvn -B -ff -ntp compile test-compile -DskipTests

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch
RUN mvn -B -ff -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
