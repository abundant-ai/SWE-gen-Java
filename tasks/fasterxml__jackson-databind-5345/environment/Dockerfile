FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 JDK
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 9a48767025c7dd4e429a5c6c0d1caff0b88ea0fe || git fetch --depth 1 origin "+refs/pull/5345/head:refs/remotes/origin/pr/5345") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

# The parent POM (tools.jackson:jackson-base:3.0.1-SNAPSHOT) is not published to the snapshot repo.
# Build and install it locally from jackson-bom (3.0 branch), overriding the version to match.
RUN git clone --depth 1 --branch 3.0 https://github.com/FasterXML/jackson-bom.git jackson-bom
RUN cd /app/jackson-bom && \
    ./mvnw -B -ntp -DskipTests -DnewVersion=3.0.1-SNAPSHOT versions:set -q && \
    ./mvnw -B -ntp -DskipTests install -q && \
    rm -rf /app/jackson-bom

WORKDIR /app/src

ENV CI=true

# Compile the project using the locally installed parent POM
RUN ./mvnw -B -ntp compile test-compile -DskipTests

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java requires recompilation)
RUN ./mvnw -B -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
