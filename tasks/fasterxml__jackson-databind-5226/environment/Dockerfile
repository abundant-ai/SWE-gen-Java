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

# Clone and install jackson-bom and jackson-base parent POMs (required dependencies)
# Using commit 9f189df which has version 3.0.0-rc6-SNAPSHOT
RUN git clone https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    git checkout 9f189df && \
    mvn clean install -N -DskipTests && \
    cd base && \
    mvn clean install -DskipTests

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin e3d570568dbd7cec3c497cfd45ee449be209e6a8 || git fetch --depth 1 origin "+refs/pull/5226/head:refs/remotes/origin/pr/5226") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables from CI config
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Compile the project (this will download dependencies and compile)
RUN ./mvnw -B -ff -ntp test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile tests after applying bug.patch (Java is a compiled language)
RUN ./mvnw -B -ff -ntp test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
