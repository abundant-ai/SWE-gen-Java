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
    (git fetch --depth 1 origin 30c238e42c30f89bf43f80938999cc166c730e45 || git fetch --depth 1 origin "+refs/pull/5394/head:refs/remotes/origin/pr/5394") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Pre-download Maven dependencies and compile (skip tests for speed)
RUN ./mvnw -B -ntp -q dependency:resolve dependency:resolve-plugins -DincludeScope=test || \
    mvn -B -ntp -q dependency:resolve dependency:resolve-plugins -DincludeScope=test

RUN ./mvnw -B -ntp -q compile test-compile -DskipTests || \
    mvn -B -ntp -q compile test-compile -DskipTests

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java compiled language)
RUN ./mvnw -B -ntp -q compile test-compile -DskipTests || \
    mvn -B -ntp -q compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
