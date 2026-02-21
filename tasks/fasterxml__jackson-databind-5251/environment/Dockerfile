FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java runtime and Maven
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 41851ca5a16030b9522365fdcacc5b572d016401 || git fetch --depth 1 origin "+refs/pull/5251/head:refs/remotes/origin/pr/5251") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Clone and install jackson-base parent POM (required dependency)
WORKDIR /app
RUN git clone --depth 1 -b 2.20 https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom/base && \
    # Update version to match jackson-databind's expected parent version
    sed -i 's/<version>2.20.3-SNAPSHOT<\/version>/<version>2.20.0-rc2-SNAPSHOT<\/version>/g' ../pom.xml && \
    sed -i 's/<version>2.20.3-SNAPSHOT<\/version>/<version>2.20.0-rc2-SNAPSHOT<\/version>/g' pom.xml && \
    # Install parent POM to local Maven repository
    cd /app/jackson-bom && \
    mvn -B -ntp install -N && \
    cd /app/jackson-bom/base && \
    mvn -B -ntp install

WORKDIR /app/src

# Install dependencies and compile
RUN ./mvnw -B -ntp test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is compiled)
RUN ./mvnw -B -ntp test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
