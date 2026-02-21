FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 JDK and Maven
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 0838f18d5c280b685d7868e414a3a0bf3080238e || git fetch --depth 1 origin "+refs/pull/5288/head:refs/remotes/origin/pr/5288") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set Java environment variables for faster compilation
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Install jackson-bom and jackson-base (parent POM for Jackson 3.x)
# jackson-parent is obsolete for Jackson 3.x; jackson-base (in jackson-bom) is used instead
# After rc9 release, version should bump back to SNAPSHOT for development
# Use commit right after the rc9 tag
RUN mkdir -p /tmp/jackson-bom && \
    cd /tmp/jackson-bom && \
    git clone https://github.com/FasterXML/jackson-bom.git . && \
    git checkout $(git rev-list -n 1 jackson-bom-3.0.0-rc9)^1 && \
    mvn -B -ntp install -DskipTests && \
    cd base && \
    mvn -B -ntp install -DskipTests && \
    cd /app/src && \
    rm -rf /tmp/jackson-bom

# Compile the project (dependencies are resolved automatically during compile)
RUN ./mvnw -B -q -ff -ntp compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java)
RUN ./mvnw -B -q -ff -ntp compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
