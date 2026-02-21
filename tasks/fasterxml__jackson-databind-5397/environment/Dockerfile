FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 and Maven
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 0534a39c901ab70a9fb801bd4dadcc6027423a42 || git fetch --depth 1 origin "+refs/pull/5397/head:refs/remotes/origin/pr/5397") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV CI=true

# Install dependencies and compile (resolves snapshot parent POM from repo)
RUN ./mvnw -B -ff -ntp -DskipTests dependency:resolve compile test-compile || \
    mvn -B -ff -ntp -DskipTests dependency:resolve compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (compiled language)
RUN ./mvnw -B -ff -ntp -DskipTests compile test-compile || \
    mvn -B -ff -ntp -DskipTests compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
