FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 21 JDK (required: test is @DisabledOnJre({JRE.JAVA_8, JRE.JAVA_11, JRE.JAVA_17}))
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/spotbugs/spotbugs.git src && \
    cd src && \
    (git fetch --depth 1 origin 11c0363e07074cc2d53d29e15a4738acc88ca386 || git fetch --depth 1 origin "+refs/pull/3646/head:refs/remotes/origin/pr/3646") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true

# Use a working sonarqube plugin version for the initial build
# (org.sonarqube 6.3.0.5676 from HEAD is not available in Gradle Central Plugin Repository)
RUN sed -i "s/id 'org.sonarqube' version '6.3.0.5676'/id 'org.sonarqube' version '6.3.1.5724'/" build.gradle

# Build the full project (compiles all subprojects including spotbugsTestCases)
RUN ./gradlew build -x test -x spotlessCheck --no-daemon

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java requires recompilation after source changes)
RUN ./gradlew build -x test -x spotlessCheck --no-daemon

RUN rm -rf /app/src/.git

WORKDIR /app/src
