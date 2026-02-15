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
    (git fetch --depth 1 origin a2cf9f4c91e003bb2a31d10b474a2f6b8cb532b2 || git fetch --depth 1 origin "+refs/pull/5036/head:refs/remotes/origin/pr/5036") && \
    git reset --hard && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Gradle
ENV CI=true
# Reduce memory usage to prevent OOM in Docker
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -Xms1g -Xmx6g"
ENV ORG_GRADLE_PROJECT_org.gradle.jvmargs="-Xms1g -Xmx6g -XX:+HeapDumpOnOutOfMemoryError"

# Override gradle.properties to use less memory (prevent OOM in Docker)
RUN echo "org.gradle.jvmargs=-Xms1g -Xmx6g -XX:MaxMetaspaceSize=1g -XX:+HeapDumpOnOutOfMemoryError" >> gradle.properties

# Download dependencies and compile the relevant modules
# This may take a while on first run as Gradle downloads dependencies
# Also compile core modules that these tests depend on
RUN ./gradlew :ktor-server-netty:compileKotlinJvm --no-daemon || true
RUN ./gradlew :ktor-server-netty:compileTestKotlinJvm --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Re-apply gradle.properties override after git reset
RUN echo "org.gradle.jvmargs=-Xms1g -Xmx6g -XX:MaxMetaspaceSize=1g -XX:+HeapDumpOnOutOfMemoryError" >> gradle.properties

# Rebuild after applying bug.patch (Kotlin needs recompilation)
RUN ./gradlew :ktor-server-netty:compileKotlinJvm --no-daemon || true
RUN ./gradlew :ktor-server-netty:compileTestKotlinJvm --no-daemon || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
