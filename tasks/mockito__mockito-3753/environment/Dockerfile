FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (required by mockito build)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install Android SDK and tools for Android instrumented tests
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Android SDK command-line tools
ENV ANDROID_SDK_ROOT=/opt/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    cd ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-9477386_latest.zip && \
    rm commandlinetools-linux-9477386_latest.zip && \
    mv cmdline-tools latest

ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"

# Accept licenses and install required SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Gradle is included in the repository via gradlew wrapper

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/mockito/mockito.git src && \
    cd src && \
    (git fetch --depth 1 origin 6bf612df32da5bd672f67ea9589997b2154d3dab || git fetch --depth 1 origin "+refs/pull/3753/head:refs/remotes/origin/pr/3753") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Android
ENV ANDROID_HOME=${ANDROID_SDK_ROOT}

# Download dependencies using Gradle
RUN ./gradlew dependencies --no-daemon || true

# Build the project (Java/Kotlin compilation)
RUN ./gradlew build -x test --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java/Kotlin needs recompilation)
RUN ./gradlew build -x test --no-daemon || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
