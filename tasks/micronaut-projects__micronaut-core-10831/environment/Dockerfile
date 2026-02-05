FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set locale to handle UTF-8 filenames
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Install locales
RUN apt-get update && apt-get install -y locales && locale-gen en_US.UTF-8 && rm -rf /var/lib/apt/lists/*

# Install Java 17 and Java 21
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/micronaut-projects/micronaut-core.git src && \
    cd src && \
    (git fetch --depth 1 origin ac53e74f1f4d3f8910872815d55d959c36e01621 || git fetch --depth 1 origin "+refs/pull/10831/head:refs/remotes/origin/pr/10831") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for build
ENV TESTCONTAINERS_RYUK_DISABLED=true
ENV CI=true

# Exclude test-suite-geb from build to avoid broken dependency (org.ysb33r.gradle:grolifant:0.5.1)
RUN sed -i 's/include "test-suite-geb"/\/\/ include "test-suite-geb"/' settings.gradle

# Download dependencies and compile the inject-kotlin module we need for testing
RUN ./gradlew \
    :inject-kotlin:compileKotlin :inject-kotlin:compileTestGroovy \
    --no-daemon --console=plain

# Reset tracked files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Exclude test-suite-geb again after applying patch
RUN sed -i 's/include "test-suite-geb"/\/\/ include "test-suite-geb"/' settings.gradle

# Rebuild after applying bug.patch (Java is a compiled language)
RUN ./gradlew \
    :inject-kotlin:compileKotlin :inject-kotlin:compileTestGroovy \
    --no-daemon --console=plain

RUN rm -rf /app/src/.git

WORKDIR /app/src
