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

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/micronaut-projects/micronaut-core.git src && \
    cd src && \
    (git fetch --depth 1 origin 9e087fe7b9dc24a6859eeb01ce4d17720db35c20 || git fetch --depth 1 origin "+refs/pull/9536/head:refs/remotes/origin/pr/9536") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for build
ENV TESTCONTAINERS_RYUK_DISABLED=true
ENV CI=true
ENV GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m"

# Exclude test-suite-geb from build to avoid broken dependency (org.ysb33r.gradle:grolifant:0.5.1)
RUN sed -i 's/include "test-suite-geb"/\/\/ include "test-suite-geb"/' settings.gradle

# Build buildSrc first to avoid jar creation race condition
RUN cd buildSrc && ../gradlew build --no-daemon --console=plain && cd ..

# Download dependencies and compile the modules we need for testing
RUN ./gradlew \
    :inject-kotlin:compileTestGroovy \
    --no-daemon --console=plain

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Exclude test-suite-geb again after applying patch
RUN sed -i 's/include "test-suite-geb"/\/\/ include "test-suite-geb"/' settings.gradle

# Rebuild after applying bug.patch (Java is a compiled language)
RUN ./gradlew \
    :inject-kotlin:compileTestGroovy \
    --no-daemon --console=plain

RUN rm -rf /app/src/.git

WORKDIR /app/src
