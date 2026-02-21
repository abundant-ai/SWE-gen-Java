FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (required by pom.xml) and Maven
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin f6331b79d4f893ed62a8bc35dc5418cd92cc9f90 || git fetch --depth 1 origin "+refs/pull/5306/head:refs/remotes/origin/pr/5306") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set Java environment variables for CI
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Install dependencies in order: jackson-bom -> jackson-base -> jackson-core
# All use version 3.0.0-rc10-SNAPSHOT to match jackson-databind
RUN cd /app && \
    git clone https://github.com/FasterXML/jackson-bom.git && \
    cd jackson-bom && \
    git checkout 34bc5d9 && \
    mvn install -N -DskipTests -Dmaven.javadoc.skip=true && \
    cd base && \
    mvn install -DskipTests -Dmaven.javadoc.skip=true && \
    cd /app && \
    git clone https://github.com/FasterXML/jackson-core.git && \
    cd jackson-core && \
    git checkout fe71216d && \
    mvn install -DskipTests -Dmaven.javadoc.skip=true

WORKDIR /app/src

# Compile the project (including test classes) - this will also resolve dependencies
RUN ./mvnw clean compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is compiled language)
RUN ./mvnw clean compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
