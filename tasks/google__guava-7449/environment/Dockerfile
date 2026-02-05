FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (JDK)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/google/guava.git src && \
    cd src && \
    (git fetch --depth 1 origin 8f747d0069eef34d845e60f9ee9f9cf5b54004b2 || git fetch --depth 1 origin "+refs/pull/7449/head:refs/remotes/origin/pr/7449") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install dependencies and compile only the required modules (skip guava-gwt to save time)
# Build: guava, guava-testlib, guava-tests (main)
RUN ./mvnw -B install -DskipTests=true -Dmaven.javadoc.skip=true -pl guava,guava-testlib,guava-tests -am
# Build: android modules
RUN ./mvnw -B install -DskipTests=true -Dmaven.javadoc.skip=true -f android/pom.xml -pl guava,guava-testlib,guava-tests -am

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java)
RUN ./mvnw -B install -DskipTests=true -Dmaven.javadoc.skip=true -pl guava,guava-testlib,guava-tests -am
RUN ./mvnw -B install -DskipTests=true -Dmaven.javadoc.skip=true -f android/pom.xml -pl guava,guava-testlib,guava-tests -am

RUN rm -rf /app/src/.git

WORKDIR /app/src
