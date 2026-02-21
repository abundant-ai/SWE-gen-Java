FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (required for test-jdk17 tests) and Maven
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone and install jackson-bom (Bill of Materials) which includes jackson-base
# Checkout the commit just before 2.20.0 release to get 2.20.0-SNAPSHOT
RUN git clone https://github.com/FasterXML/jackson-bom.git && \
    cd jackson-bom && \
    git checkout jackson-bom-2.20.0^ && \
    ./mvnw -B -ntp clean install -DskipTests && \
    cd ..

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 01dda7c902f3f5dab9cd295730848deba16c636b || git fetch --depth 1 origin "+refs/pull/5224/head:refs/remotes/origin/pr/5224") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for faster Maven builds
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Build the project (this will download dependencies and compile)
RUN ./mvnw -B -ntp clean test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java)
RUN ./mvnw -B -ntp clean test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
