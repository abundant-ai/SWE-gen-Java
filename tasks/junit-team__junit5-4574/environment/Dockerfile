FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java (JDK 21, 17 for tests, and JDK 24/25 for build system)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    openjdk-17-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download and install JDK 24
RUN wget -q https://download.java.net/java/GA/jdk24/1f9ff9062db4449d8ca828c504ffae90/36/GPL/openjdk-24_linux-x64_bin.tar.gz && \
    mkdir -p /usr/lib/jvm && \
    tar -xzf openjdk-24_linux-x64_bin.tar.gz -C /usr/lib/jvm && \
    rm openjdk-24_linux-x64_bin.tar.gz && \
    mv /usr/lib/jvm/jdk-24 /usr/lib/jvm/java-24-openjdk

# Download and install JDK 25
RUN wget -q https://download.java.net/java/GA/jdk25.0.2/b1e0dfa218384cb9959bdcb897162d4e/10/GPL/openjdk-25.0.2_linux-x64_bin.tar.gz && \
    mkdir -p /usr/lib/jvm && \
    tar -xzf openjdk-25.0.2_linux-x64_bin.tar.gz -C /usr/lib/jvm && \
    rm openjdk-25.0.2_linux-x64_bin.tar.gz && \
    mv /usr/lib/jvm/jdk-25.0.2 /usr/lib/jvm/java-25-openjdk

# Set Java 25 as default for Gradle build
ENV JAVA_HOME=/usr/lib/jvm/java-25-openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV JDK24=/usr/lib/jvm/java-24-openjdk
ENV JDK21=/usr/lib/jvm/java-21-openjdk-amd64
ENV JDK17=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/junit-team/junit-framework.git src && \
    cd src && \
    (git fetch --depth 1 origin 049ade0638d5b40df79aed3f87ab5d16a5df3c26 || git fetch --depth 1 origin "+refs/pull/4574/head:refs/remotes/origin/pr/4574") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download dependencies and build the project
RUN ./gradlew --no-daemon dependencies testClasses --no-configuration-cache

# Reset files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch
RUN ./gradlew --no-daemon testClasses --no-configuration-cache

WORKDIR /app/src
