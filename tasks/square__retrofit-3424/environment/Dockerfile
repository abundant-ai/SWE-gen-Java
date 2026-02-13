FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 11 (required for Gradle 7.1)
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && apt-get install -y temurin-11-jdk && \
    rm -rf /var/lib/apt/lists/*

# Set Java 11 as the default
RUN update-alternatives --set java /usr/lib/jvm/temurin-11-jdk-amd64/bin/java || true && \
    update-alternatives --set javac /usr/lib/jvm/temurin-11-jdk-amd64/bin/javac || true

ENV JAVA_HOME=/usr/lib/jvm/temurin-11-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/retrofit.git src && \
    cd src && \
    (git fetch --depth 1 origin 56e15f806198c18a17dc3407a013fcc1652f1b01 || git fetch --depth 1 origin "+refs/pull/3424/head:refs/remotes/origin/pr/3424") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for CI
ENV CI=true
ENV GRADLE_OPTS="-Xmx4g -Dorg.gradle.daemon=false"
ENV ORG_GRADLE_PROJECT_org_gradle_java_home=/usr/lib/jvm/temurin-11-jdk-amd64

# Download dependencies and build the project using Gradle
RUN chmod +x gradlew && ./gradlew build -x test || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is a compiled language)
RUN ./gradlew build -x test || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
