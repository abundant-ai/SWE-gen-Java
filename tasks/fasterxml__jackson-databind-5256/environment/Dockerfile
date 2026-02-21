FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (project compiles with Java 8 target, tests run on newer JDK)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 09e8ed65a3c73f4247d4055ddb7bb29ff977d0a1 || git fetch --depth 1 origin "+refs/pull/5256/head:refs/remotes/origin/pr/5256") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Patch pom.xml to use released parent version instead of SNAPSHOT
# Only change the version within the <parent> section (lines 9-13)
RUN sed -i '9,13s|<version>2.20.0-rc2-SNAPSHOT</version>|<version>2.20.1</version>|' pom.xml && \
    sed -i '/<parent>/,/<\/parent>/s|</version>|</version>\n    <relativePath/>|' pom.xml

# Install dependencies and compile the project
RUN ./mvnw -B -ntp clean test-compile -DskipTests

# If install/build steps touched tracked files, reset them (except pom.xml) so bug.patch applies cleanly
# Save the patched pom.xml, reset, then restore it
RUN cp pom.xml /tmp/pom.xml.patched && \
    git reset --hard && \
    mv /tmp/pom.xml.patched pom.xml

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is compiled)
RUN ./mvnw -B -ntp clean test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
