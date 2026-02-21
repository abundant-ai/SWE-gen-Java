FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 (project baseline is Java 8)
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 357b6d410832050de4fdc5efdabae113dd939ffa || git fetch --depth 1 origin "+refs/pull/5249/head:refs/remotes/origin/pr/5249") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set Java options for faster builds (from CI config)
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Fix parent POM issue - use released version instead of SNAPSHOT
RUN sed -i 's/<version>2\.20\.0-rc2-SNAPSHOT<\/version>/<version>2.20.0<\/version>/g' pom.xml

# Install dependencies and compile the project
RUN ./mvnw -B -ff -ntp test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Fix parent POM issue after patch - use released version instead of SNAPSHOT
RUN sed -i 's/<version>2\.20\.0-rc2-SNAPSHOT<\/version>/<version>2.20.0<\/version>/g' pom.xml

# Rebuild after applying bug.patch
RUN ./mvnw -B -ff -ntp test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
