FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (required by pom.xml: javac.src.version=17)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 77c370f7305de9614834ea3b47215629e2b0226b || git fetch --depth 1 origin "+refs/pull/5574/head:refs/remotes/origin/pr/5574") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true

# Download and cache Maven dependencies
RUN ./mvnw -B -ntp dependency:resolve dependency:resolve-plugins -Dmaven.test.skip=true || true

# Build the project (compile main and test sources)
RUN ./mvnw -B -ntp compile test-compile -Dmaven.test.skip=true || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java requires recompilation)
RUN ./mvnw -B -ntp compile test-compile -Dmaven.test.skip=true

RUN rm -rf /app/src/.git

WORKDIR /app/src
