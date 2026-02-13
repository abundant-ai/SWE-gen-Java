FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 (required for Maven build at this commit)
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    maven \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && apt-get install -y temurin-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# Set Java 8 as the default
RUN update-alternatives --set java /usr/lib/jvm/temurin-8-jdk-amd64/bin/java || true && \
    update-alternatives --set javac /usr/lib/jvm/temurin-8-jdk-amd64/bin/javac || true

ENV JAVA_HOME=/usr/lib/jvm/temurin-8-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Build OkHttp 3.0.0-SNAPSHOT (required dependency at this commit)
# Using commit ee83d8d2 which is the last SNAPSHOT version before RC1
RUN git clone https://github.com/square/okhttp.git okhttp && \
    cd okhttp && \
    git checkout ee83d8d26afd92d27fbcd2a328e882f25a5090c6 && \
    mvn clean install -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/retrofit.git src && \
    cd src && \
    (git fetch --depth 1 origin 6359791fdaeafa0523ea2bd7da29da4dbe6eb124 || git fetch --depth 1 origin "+refs/pull/1038/head:refs/remotes/origin/pr/1038") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for CI
ENV CI=true
ENV MAVEN_OPTS="-Xmx2g"

# Download dependencies and build the project using Maven
RUN mvn clean install -DskipTests -Dmaven.javadoc.skip=true || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
# Note: checkstyle.xml may fail due to line endings, but it's not critical for tests
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch || echo "Some hunks failed (likely checkstyle.xml line endings)" && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is a compiled language)
RUN mvn clean install -DskipTests -Dmaven.javadoc.skip=true || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
