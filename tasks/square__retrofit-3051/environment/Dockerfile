FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 (project requires Java 1.8 as specified in pom.xml)
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && apt-get install -y temurin-8-jdk && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/temurin-8-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/retrofit.git src && \
    cd src && \
    (git fetch --depth 1 origin 083bf240fab810dee2d4570c74061983bf25136a || git fetch --depth 1 origin "+refs/pull/3051/head:refs/remotes/origin/pr/3051") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for CI
ENV CI=true
ENV MAVEN_OPTS="-Xmx4g"

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Download dependencies and build the project
RUN mvn clean install -DskipTests || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN apt-get update && apt-get install -y dos2unix && rm -rf /var/lib/apt/lists/* && \
    dos2unix checkstyle.xml && \
    patch -p1 < /tmp/bug.patch && \
    rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is a compiled language)
RUN mvn clean install -DskipTests || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
