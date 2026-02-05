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
    (git fetch --depth 1 origin c2bc00314dec5d9299bd6879fca1031e352047f8 || git fetch --depth 1 origin "+refs/pull/11110/head:refs/remotes/origin/pr/11110") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for build
ENV TESTCONTAINERS_RYUK_DISABLED=true
ENV CI=true
ENV GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m"

# Build buildSrc first to avoid jar creation race condition
RUN cd buildSrc && ../gradlew build --no-daemon --console=plain && cd ..

# Download dependencies and compile http-client module that contains the test files
RUN cd http-client && ../gradlew compileJava compileGroovy compileTestGroovy compileTestJava --no-daemon --console=plain && cd ..

# Reset tracked files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is a compiled language)
RUN cd http-client && ../gradlew compileJava compileGroovy compileTestGroovy compileTestJava --no-daemon --console=plain && cd ..

RUN rm -rf /app/src/.git

WORKDIR /app/src
