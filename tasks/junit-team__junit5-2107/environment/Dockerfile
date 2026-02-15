FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 17 (required by JUnit 5 build)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Disable git versioning plugin to avoid grgit dependency issues
ENV GRADLE_PROJECT_release.useLastTag=false

# Disable Kotlin's allWarningsAsErrors to allow deprecated language version warnings
ENV ORG_GRADLE_PROJECT_kotlin.allWarningsAsErrors=false

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/junit-team/junit-framework.git src && \
    cd src && \
    (git fetch --depth 1 origin 71d8cec8b323322d2e4bcd34e17d34b2bd93ae47 || git fetch --depth 1 origin "+refs/pull/2107/head:refs/remotes/origin/pr/2107") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Build the project and publish to Maven local to resolve dependencies
RUN ./gradlew build publishToMavenLocal -x test --no-daemon || \
    (sleep 2 && ./gradlew build publishToMavenLocal -x test --no-daemon) || \
    (sleep 5 && ./gradlew build publishToMavenLocal -x test --no-daemon)

# Reset tracked files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch
RUN ./gradlew build publishToMavenLocal -x test --no-daemon || \
    (sleep 2 && ./gradlew build publishToMavenLocal -x test --no-daemon) || \
    (sleep 5 && ./gradlew build publishToMavenLocal -x test --no-daemon)

WORKDIR /app/src
