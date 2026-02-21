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
RUN apt-get update && apt-get install -y openjdk-17-jdk maven && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 3511e724d09dde7e8fdb22a2666113ee47498b65 || git fetch --depth 1 origin "+refs/pull/5477/head:refs/remotes/origin/pr/5477") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Pre-download dependencies and compile (caches Maven artifacts)
RUN ./mvnw -B -ntp dependency:resolve dependency:resolve-plugins -DskipTests
RUN ./mvnw -B -ntp compile test-compile -DskipTests

# Reset any files modified by build so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java requires recompilation)
RUN ./mvnw -B -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
