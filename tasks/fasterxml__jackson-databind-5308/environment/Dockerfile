FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (required by pom.xml)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone and install jackson-bom parent POMs at the commit before rc10 release
RUN git clone https://github.com/FasterXML/jackson-bom.git && \
    cd jackson-bom && \
    git checkout 0e099b2 && \
    mvn -B install -N -DskipTests && \
    cd base && \
    mvn -B install -DskipTests && \
    cd /app && \
    rm -rf jackson-bom

# Clone and install jackson-core dependency (required for jackson-databind)
RUN git clone https://github.com/FasterXML/jackson-core.git && \
    cd jackson-core && \
    git checkout 0e0c7ef6 && \
    ./mvnw -B install -DskipTests && \
    cd /app && \
    rm -rf jackson-core

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 2bde18b96d60496d6285a806ffb88971e51ce946 || git fetch --depth 1 origin "+refs/pull/5308/head:refs/remotes/origin/pr/5308") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set Java environment variables for CI
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Compile the project (this will also download dependencies)
RUN ./mvnw -B compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java)
RUN ./mvnw -B compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
