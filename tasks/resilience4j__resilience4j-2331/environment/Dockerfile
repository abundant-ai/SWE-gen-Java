FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 21 (for HEAD build) and Java 17 (for post-patch build with Gradle 7.x)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME to Java 21 for initial build
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/resilience4j/resilience4j.git src && \
    cd src && \
    (git fetch --depth 1 origin a664c7a5e3534f662711fcc686c865b792cf8156 || git fetch --depth 1 origin "+refs/pull/2331/head:refs/remotes/origin/pr/2331") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install dependencies and compile Java code using Java 21 (HEAD requires Java 21)
RUN ./gradlew compileJava compileTestJava --no-daemon

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Switch to Java 17 for post-patch build (bug.patch downgrades Gradle wrapper to 7.x which requires Java 17)
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Clear Gradle caches so the new Gradle version downloads fresh
RUN rm -rf /root/.gradle/caches

# Rebuild after patching Java source files using Java 17
RUN ./gradlew compileJava compileTestJava --no-daemon

RUN rm -rf /app/src/.git

# Restore JAVA_HOME for test runner (tests run under buggy state with Java 17)
WORKDIR /app/src
