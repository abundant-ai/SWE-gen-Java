FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 and Maven (required by pom.xml)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone and install jackson-bom (parent POM required by jackson-databind)
# Need to checkout the commit right after rc10 tag to get 3.0.0-rc10-SNAPSHOT
RUN git clone https://github.com/FasterXML/jackson-bom.git bom && \
    cd bom && \
    git checkout jackson-bom-3.0.0-rc10 && \
    git log --oneline -1 && \
    sed -i 's/<version>3.0.0-rc10<\/version>/<version>3.0.0-rc10-SNAPSHOT<\/version>/g' pom.xml base/pom.xml && \
    mvn -B -ff -ntp install -DskipTests

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin c140bc87a22d69fbd67f0a8b40c8962698fe9712 || git fetch --depth 1 origin "+refs/pull/5303/head:refs/remotes/origin/pr/5303") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set Java environment variables
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Install dependencies and compile the project
RUN ./mvnw -B -ff -ntp compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is compiled)
RUN ./mvnw -B -ff -ntp compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
