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

# Install jackson-bom and jackson-base parent POMs (3.0.0-rc10-SNAPSHOT).
# The parent POM is not published to the public snapshot repo, so we must build it locally.
# We use the jackson-bom commit that contains the 3.0.0-rc10-SNAPSHOT version
# (commit ce6fbc2 is the "Prep for 3.0.0-rc10" commit just before the release tag).
RUN git clone https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    git checkout ce6fbc224ad8e8640c409a15df2b404346b714b0 && \
    ./mvnw -B -ntp install -DskipTests -N && \
    cd base && \
    /app/jackson-bom/mvnw -B -ntp install -DskipTests && \
    cd /app && rm -rf jackson-bom

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 1670007d4c6295d431f3c40ddb36a4794543cecb || git fetch --depth 1 origin "+refs/pull/5310/head:refs/remotes/origin/pr/5310") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install dependencies and compile (skip tests during dependency resolution)
RUN ./mvnw -B -ff -ntp dependency:resolve && \
    ./mvnw -B -ff -ntp compile test-compile -DskipTests

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java requires recompilation)
RUN ./mvnw -B -ff -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
