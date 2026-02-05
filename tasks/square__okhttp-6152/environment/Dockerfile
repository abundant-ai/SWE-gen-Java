FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install additional system packages
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Java 11, 17, and 21
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    openjdk-17-jdk \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set Java 17 as default for Android SDK installation
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install Android SDK Command Line Tools
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    cd ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip commandlinetools-linux-*_latest.zip && \
    rm commandlinetools-linux-*_latest.zip && \
    mv cmdline-tools latest

# Accept Android SDK licenses and install required SDK components
RUN yes | sdkmanager --licenses || true && \
    sdkmanager "platforms;android-35" "platform-tools" "build-tools;35.0.0"

# Switch to Java 11 for building the project (Kotlin compiler compatibility)
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Create symlinks for Gradle compatibility (remove existing dirs first)
RUN rm -rf /usr/lib/jvm/openjdk-11 && ln -s /usr/lib/jvm/java-11-openjdk-amd64 /usr/lib/jvm/openjdk-11 && \
    rm -rf /usr/lib/jvm/openjdk-17 && ln -s /usr/lib/jvm/java-17-openjdk-amd64 /usr/lib/jvm/openjdk-17 && \
    rm -rf /usr/lib/jvm/openjdk-21 && ln -s /usr/lib/jvm/java-21-openjdk-amd64 /usr/lib/jvm/openjdk-21

WORKDIR /app

# Configure git to use https:// instead of git:// for submodules
RUN git config --global url."https://github.com/".insteadOf git://github.com/

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/okhttp.git src && \
    cd src && \
    (git fetch --depth 1 origin 2e41bd7652afe8766b5299f59179f934242bda91 || git fetch --depth 1 origin "+refs/pull/6152/head:refs/remotes/origin/pr/6152") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables as per CI config
ENV GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Download dependencies using Gradle wrapper
RUN ./gradlew dependencies --no-daemon || true

# Build the project (compile main sources only, skip test compilation to avoid issues with bug.patch)
RUN ./gradlew :okhttp-tls:compileKotlinJvm --no-daemon || true

# Reset any tracked files modified during build to ensure bug.patch applies cleanly
RUN git reset --hard && git clean -fd

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild main sources after applying bug.patch (skip test compilation)
RUN ./gradlew :okhttp-tls:compileKotlinJvm --no-daemon || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
