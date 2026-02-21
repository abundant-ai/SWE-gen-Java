FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (JDK) and Maven
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 347678e10cc2e87c6cad4904b17d19b63cb1800a || git fetch --depth 1 origin "+refs/pull/5591/head:refs/remotes/origin/pr/5591") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Pre-download dependencies and compile (without running tests)
RUN mvn -B -ntp dependency:resolve dependency:resolve-plugins -q || true
RUN mvn -B -ntp compile test-compile -DskipTests -q || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild test classes after applying bug.patch
RUN mvn -B -ntp compile test-compile -DskipTests -q || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
