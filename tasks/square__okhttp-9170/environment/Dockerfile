FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Java 11, 17, and 21
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    openjdk-17-jdk \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set Java 17 as default
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

WORKDIR /app

# Configure git to use https:// instead of git:// for submodules
RUN git config --global url."https://github.com/".insteadOf git://github.com/

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/okhttp.git src && \
    cd src && \
    (git fetch --depth 1 origin 63d9777757ff77bc39af3de7e9c0ca2b3026dd75 || git fetch --depth 1 origin "+refs/pull/9170/head:refs/remotes/origin/pr/9170") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables as per CI config
ENV GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Download dependencies using Gradle wrapper
RUN ./gradlew dependencies --no-daemon || true

# Build the project (compile main sources first, then test sources)
RUN ./gradlew :okhttp:compileKotlinJvm --no-daemon || true
RUN ./gradlew compileTestKotlin --no-daemon || true

# Reset any tracked files modified during build to ensure bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch
RUN ./gradlew :okhttp:compileKotlinJvm --no-daemon || true
RUN ./gradlew compileTestKotlin --no-daemon || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
