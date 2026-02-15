FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 21 for Kotlin/Gradle project
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
# Use -c core.autocrlf=false to prevent line ending issues on checkout
RUN git clone -c core.autocrlf=false https://github.com/ktorio/ktor.git src && \
    cd src && \
    git config core.autocrlf false && \
    (git fetch --depth 1 origin 0605623c18d4aeb4fcf203fdad741b89432b52de || git fetch --depth 1 origin "+refs/pull/4981/head:refs/remotes/origin/pr/4981") && \
    git checkout --detach --force FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Gradle
ENV CI=true
# Reduce memory usage to prevent OOM in Docker (container has 2GB total)
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -Xms512m -Xmx1536m"
ENV ORG_GRADLE_PROJECT_org.gradle.jvmargs="-Xms512m -Xmx1536m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+UseParallelGC"

# Override gradle.properties to use less memory (prevent OOM in Docker)
RUN echo "org.gradle.jvmargs=-Xms512m -Xmx1536m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+UseParallelGC" >> gradle.properties

# Download dependencies and compile the relevant modules
# This may take a while on first run as Gradle downloads dependencies
# Also compile core modules that these tests depend on
RUN ./gradlew :ktor-network:compileKotlinJvm --no-daemon || true
RUN ./gradlew :ktor-network:compileTestKotlinJvm --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Re-apply gradle.properties override after git reset
RUN echo "org.gradle.jvmargs=-Xms512m -Xmx1536m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+UseParallelGC" >> gradle.properties

# Rebuild after applying bug.patch (Kotlin needs recompilation)
RUN ./gradlew :ktor-network:compileKotlinJvm --no-daemon || true
RUN ./gradlew :ktor-network:compileTestKotlinJvm --no-daemon || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
