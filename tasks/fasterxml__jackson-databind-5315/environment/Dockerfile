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
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Build jackson-bom (including jackson-base module) from rc10 tag and install as SNAPSHOT
# jackson-databind requires tools.jackson:jackson-base:3.0.0-rc10-SNAPSHOT
RUN git clone --depth 1 -b jackson-bom-3.0.0-rc10 https://github.com/FasterXML/jackson-bom.git /tmp/jackson-bom && \
    cd /tmp/jackson-bom && \
    mvn -B -ntp versions:set -DnewVersion=3.0.0-rc10-SNAPSHOT -DgenerateBackupPoms=false && \
    mvn -B -ntp install -DskipTests && \
    rm -rf /tmp/jackson-bom

# Build jackson-core from rc10 tag and install as SNAPSHOT
# jackson-databind requires tools.jackson.core:jackson-core:3.0.0-rc10-SNAPSHOT
RUN git clone --depth 1 -b jackson-core-3.0.0-rc10 https://github.com/FasterXML/jackson-core.git /tmp/jackson-core && \
    cd /tmp/jackson-core && \
    mvn -B -ntp versions:set -DnewVersion=3.0.0-rc10-SNAPSHOT -DgenerateBackupPoms=false && \
    mvn -B -ntp install -DskipTests && \
    rm -rf /tmp/jackson-core

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 25c30db05e574af8ea28f6970bf4a35c5d3656cf || git fetch --depth 1 origin "+refs/pull/5315/head:refs/remotes/origin/pr/5315") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install dependencies and compile (uses locally installed SNAPSHOT parent POMs)
RUN mvn -B -ntp compile test-compile -DskipTests

# Reset any files touched during build so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch (Java must be recompiled after source changes)
RUN mvn -B -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
