FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (required by pom.xml javac.src.version)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /app

# Clone and install parent POM (jackson-bom/base)
# Use rc7 tag and manually set version to rc7-SNAPSHOT for databind compatibility
RUN git clone https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    git checkout jackson-bom-3.0.0-rc7 && \
    # Update version from rc7 to rc7-SNAPSHOT in both bom and base
    sed -i 's/<version>3.0.0-rc7<\/version>/<version>3.0.0-rc7-SNAPSHOT<\/version>/g' pom.xml base/pom.xml && \
    ./mvnw -B -ff -ntp install -DskipTests

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 02a8a3a8df0798333be8524582bad45fc3886cb2 || git fetch --depth 1 origin "+refs/pull/5235/head:refs/remotes/origin/pr/5235") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set Java-specific environment variables
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Compile the project (this will also download dependencies)
RUN ./mvnw -B -ff -ntp compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is a compiled language)
RUN ./mvnw -B -ff -ntp compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
