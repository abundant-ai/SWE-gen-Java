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
    (git fetch --depth 1 origin 3d0e0282c26bd3dfab05ae9a78e71b812c7ca72e || git fetch --depth 1 origin "+refs/pull/52470/head:refs/remotes/origin/pr/52470") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Maven builds
ENV LANG=en_US.UTF-8
ENV MAVEN_OPTS="-Xmx2g"

# Build the modules containing the test files
RUN mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl extensions/oidc-common/runtime,extensions/oidc-common/deployment -am \
    clean install

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild modules after bug.patch to ensure buggy code is compiled
# Note: Skip test compilation (-Dmaven.test.skip=true) because the buggy state has test compilation errors
RUN mvn -e -B --settings .github/mvn-settings.xml -Dmaven.test.skip=true -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation \
    -pl extensions/oidc-common/runtime,extensions/oidc-common/deployment \
    clean install

RUN rm -rf /app/src/.git

WORKDIR /app/src
