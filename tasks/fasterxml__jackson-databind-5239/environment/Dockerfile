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

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /app

# Clone jackson-bom first (contains parent POM jackson-base) - use 2.x branch
RUN git clone --depth 1 --branch 2.x https://github.com/FasterXML/jackson-bom.git jackson-bom

# Install jackson-bom and jackson-base parent POMs locally to match expected version
WORKDIR /app/jackson-bom
RUN ./mvnw -B -ntp versions:set -DnewVersion=2.20.0-SNAPSHOT && \
    ./mvnw -B -ntp install -N && \
    ./mvnw -B -ntp -f base/pom.xml install -N

# Clone repo at HEAD commit (with fix applied)
WORKDIR /app
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 7d06fc5956b984d5f8aa45b0663662e7c65b8f91 || git fetch --depth 1 origin "+refs/pull/5239/head:refs/remotes/origin/pr/5239") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Maven
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
ENV MAVEN_OPTS="-Xmx1024m"

# Compile main sources and test sources (this will also download dependencies)
RUN ./mvnw -B -ntp clean compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java)
RUN ./mvnw -B -ntp clean compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
