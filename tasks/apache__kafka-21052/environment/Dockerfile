FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 17 (required by Kafka)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/apache/kafka.git src && \
    cd src && \
    (git fetch --depth 1 origin 334c96dc59757928d3ababe25bfa88dda47ec70f || git fetch --depth 1 origin "+refs/pull/21052/head:refs/remotes/origin/pr/21052") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Build the required modules to compile classes and download dependencies
RUN ./gradlew :coordinator-common:testClasses :group-coordinator:testClasses \
    --no-daemon --no-configuration-cache \
    -Dorg.gradle.jvmargs="-Xmx8g -Xss4m" -Dorg.gradle.workers.max=1 \
    -x checkstyle -x spotbugs -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java)
RUN ./gradlew :coordinator-common:testClasses :group-coordinator:testClasses \
    --no-daemon --no-configuration-cache \
    -Dorg.gradle.jvmargs="-Xmx8g -Xss4m" -Dorg.gradle.workers.max=1 \
    -x checkstyle -x spotbugs -x checkstyleMain -x checkstyleTest -x spotbugsMain -x spotbugsTest

RUN rm -rf /app/src/.git

WORKDIR /app/src
