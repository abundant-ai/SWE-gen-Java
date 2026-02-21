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

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 01ddccafe219e1e58c3d3529fae8c06b118f662a || git fetch --depth 1 origin "+refs/pull/5656/head:refs/remotes/origin/pr/5656") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV CI=true

# Download dependencies and compile (skip tests to speed up)
# jackson-databind has a SNAPSHOT parent, enable snapshots repository
RUN mvn -B -ntp dependency:resolve -DincludeScope=test \
    -Dmaven.test.skip=true \
    || mvn -B -ntp install -DskipTests 2>&1 | tail -20

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch
RUN mvn -B -ntp compile test-compile -DskipTests 2>&1 | tail -20

RUN rm -rf /app/src/.git

WORKDIR /app/src
