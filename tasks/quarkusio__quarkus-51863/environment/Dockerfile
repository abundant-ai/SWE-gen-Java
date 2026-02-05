FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (required by Quarkus)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Download and install Maven 3.9.12 to match wrapper requirements
RUN curl -fsSL https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.12/apache-maven-3.9.12-bin.tar.gz | tar -xz -C /opt && \
    ln -s /opt/apache-maven-3.9.12/bin/mvn /usr/local/bin/mvn
ENV PATH="/opt/apache-maven-3.9.12/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/quarkusio/quarkus.git src && \
    cd src && \
    (git fetch --depth 1 origin 8d85d1426155ded1bc303d9a0911b98fc5844058 || git fetch --depth 1 origin "+refs/pull/51863/head:refs/remotes/origin/pr/51863") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Maven builds
ENV LANG=en_US.UTF-8
ENV MAVEN_OPTS="-Xmx2g"

# Build the affected modules and their dependencies using Maven reactor
# Use -am (also-make) to build dependencies of the specified modules
RUN mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl devtools/maven,extensions/resteasy-reactive/rest-jackson/deployment -am \
    clean install

# Reset any tracked files modified by build steps so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java compiled project)
RUN mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl devtools/maven,extensions/resteasy-reactive/rest-jackson/deployment -am \
    clean install

RUN rm -rf /app/src/.git

WORKDIR /app/src
