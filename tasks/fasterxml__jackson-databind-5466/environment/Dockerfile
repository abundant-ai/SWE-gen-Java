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
ENV CI=true

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 63d9d5d6a1135ef5839f3953167ed6c2ed8131e5 || git fetch --depth 1 origin "+refs/pull/5466/head:refs/remotes/origin/pr/5466") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Pre-download all Maven dependencies (including snapshot parent from Sonatype Central)
RUN mvn dependency:resolve -B -ntp -q || true
RUN mvn dependency:resolve-plugins -B -ntp -q || true

# Build the project to compile sources and cache everything
RUN mvn compile test-compile -B -ntp -DskipTests

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after patching (Java requires recompilation)
RUN mvn compile test-compile -B -ntp -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
