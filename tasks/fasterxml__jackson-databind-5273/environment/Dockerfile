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

# Clone and install jackson-bom and jackson-base parent POMs (required dependencies)
RUN git clone https://github.com/FasterXML/jackson-bom.git jackson-base-pom && \
    cd jackson-base-pom && \
    git checkout deb63af && \
    mvn -B -q clean install -N && \
    cd base && \
    mvn -B -q clean install -DskipTests

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin a927e9fb8618ab7ed7d55292ae3192f242f40ea1 || git fetch --depth 1 origin "+refs/pull/5273/head:refs/remotes/origin/pr/5273") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set Java environment variables
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Fix pom.xml to use repository parent instead of relative path
RUN sed -i '/<parent>/,/<\/parent>/s|</parent>|  <relativePath/>\n  </parent>|' pom.xml

# Build the project (this will also resolve dependencies)
RUN mvn -B -q -ff -ntp compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is compiled)
RUN mvn -B -q -ff -ntp compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
