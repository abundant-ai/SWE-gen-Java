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

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV CI=true

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 9bf78ea0bf520c51ae3a45cead6a21e238d06327 || git fetch --depth 1 origin "+refs/pull/5486/head:refs/remotes/origin/pr/5486") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Maven dependencies (cache them in the image)
RUN mvn dependency:resolve -B -q -DskipTests 2>/dev/null || mvn dependency:resolve -B -DskipTests

# Compile the project (to cache compiled classes)
RUN mvn compile test-compile -B -q -DskipTests

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch
RUN mvn compile test-compile -B -q -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
