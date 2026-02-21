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

# Build and install jackson-bom + jackson-base 3.0.3-SNAPSHOT to satisfy the
# jackson-databind parent POM dependency (not available in Maven Central Snapshots)
RUN git clone --depth 1 --branch jackson-bom-3.0.3 https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    mvn -B -ff -ntp versions:set -DnewVersion=3.0.3-SNAPSHOT -DprocessAllModules && \
    mvn -B -ff -ntp install -DskipTests -N && \
    cd base && mvn -B -ff -ntp install -DskipTests && \
    cd /app && rm -rf jackson-bom

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 9c57e932d804b07e999f2adc62879e7d80a289a7 || git fetch --depth 1 origin "+refs/pull/5422/head:refs/remotes/origin/pr/5422") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download dependencies and compile (caches Maven artifacts)
RUN mvn -B -ff -ntp compile test-compile -DskipTests

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java requires recompilation)
RUN mvn -B -ff -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
