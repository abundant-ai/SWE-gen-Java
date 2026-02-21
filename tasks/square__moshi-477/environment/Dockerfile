FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 and Maven (this project uses Maven and Java 1.7 target, need Java 8 to compile)
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Use Java 8 for BASE state (needed to compile to Java 1.7 target)
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/moshi.git src && \
    cd src && \
    (git fetch --depth 1 origin a931184edfc35102a7db64d48d6b33c3eb4a323a || git fetch --depth 1 origin "+refs/pull/477/head:refs/remotes/origin/pr/477") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Maven dependencies and compile the project
RUN mvn install -DskipTests -Dcheckstyle.skip

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for compiled languages)
RUN mvn install -DskipTests -Dcheckstyle.skip

RUN rm -rf /app/src/.git

WORKDIR /app/src
