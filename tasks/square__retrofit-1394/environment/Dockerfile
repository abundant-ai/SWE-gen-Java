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
    (git fetch --depth 1 origin 0dca9b0529ab699d2955932c0f5eeedf51170014 || git fetch --depth 1 origin "+refs/pull/1394/head:refs/remotes/origin/pr/1394") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for CI
ENV CI=true
ENV MAVEN_OPTS="-Xmx4g"

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Build OkHttp 3.0.0-SNAPSHOT dependency (retrofit depends on this snapshot version)
# Download and install a compatible OkHttp 3.x version as 3.0.0-SNAPSHOT
# Use 3.0.0-RC1 from Maven Central and install it as 3.0.0-SNAPSHOT
RUN mkdir -p /root/.m2/repository/com/squareup/okhttp3/okhttp/3.0.0-SNAPSHOT && \
    mkdir -p /root/.m2/repository/com/squareup/okhttp3/mockwebserver/3.0.0-SNAPSHOT && \
    curl -L https://repo1.maven.org/maven2/com/squareup/okhttp3/okhttp/3.0.0-RC1/okhttp-3.0.0-RC1.jar -o /root/.m2/repository/com/squareup/okhttp3/okhttp/3.0.0-SNAPSHOT/okhttp-3.0.0-SNAPSHOT.jar && \
    curl -L https://repo1.maven.org/maven2/com/squareup/okhttp3/okhttp/3.0.0-RC1/okhttp-3.0.0-RC1.pom -o /root/.m2/repository/com/squareup/okhttp3/okhttp/3.0.0-SNAPSHOT/okhttp-3.0.0-SNAPSHOT.pom && \
    curl -L https://repo1.maven.org/maven2/com/squareup/okhttp3/mockwebserver/3.0.0-RC1/mockwebserver-3.0.0-RC1.jar -o /root/.m2/repository/com/squareup/okhttp3/mockwebserver/3.0.0-SNAPSHOT/mockwebserver-3.0.0-SNAPSHOT.jar && \
    curl -L https://repo1.maven.org/maven2/com/squareup/okhttp3/mockwebserver/3.0.0-RC1/mockwebserver-3.0.0-RC1.pom -o /root/.m2/repository/com/squareup/okhttp3/mockwebserver/3.0.0-SNAPSHOT/mockwebserver-3.0.0-SNAPSHOT.pom

WORKDIR /app/src

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
