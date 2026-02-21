FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 and Maven (Java 17 is the baseline for this project)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV CI=true
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Pre-install jackson-base and jackson-bom parent POMs as SNAPSHOTs in local Maven repo.
# jackson-databind 3.0.3-SNAPSHOT requires parent tools.jackson:jackson-base:3.0.3-SNAPSHOT
# which is not published to the snapshot repo yet, so we install the 3.0.3 release as SNAPSHOT.
RUN mkdir -p /root/.m2/repository/tools/jackson/jackson-bom/3.0.3-SNAPSHOT && \
    mkdir -p /root/.m2/repository/tools/jackson/jackson-base/3.0.3-SNAPSHOT && \
    # Download jackson-bom 3.0.3 release POM and install as SNAPSHOT
    curl -s "https://repo1.maven.org/maven2/tools/jackson/jackson-bom/3.0.3/jackson-bom-3.0.3.pom" \
        -o /root/.m2/repository/tools/jackson/jackson-bom/3.0.3-SNAPSHOT/jackson-bom-3.0.3-SNAPSHOT.pom && \
    # Download jackson-base 3.0.3 release POM and install as SNAPSHOT
    curl -s "https://repo1.maven.org/maven2/tools/jackson/jackson-base/3.0.3/jackson-base-3.0.3.pom" \
        -o /root/.m2/repository/tools/jackson/jackson-base/3.0.3-SNAPSHOT/jackson-base-3.0.3-SNAPSHOT.pom && \
    # Create maven-metadata-local.xml for both artifacts
    echo '<?xml version="1.0" encoding="UTF-8"?><metadata><groupId>tools.jackson</groupId><artifactId>jackson-bom</artifactId><version>3.0.3-SNAPSHOT</version><versioning><snapshot><localCopy>true</localCopy></snapshot><lastUpdated>20250101000000</lastUpdated><snapshotVersions><snapshotVersion><extension>pom</extension><value>3.0.3-SNAPSHOT</value><updated>20250101000000</updated></snapshotVersion></snapshotVersions></versioning></metadata>' \
        > /root/.m2/repository/tools/jackson/jackson-bom/3.0.3-SNAPSHOT/maven-metadata-local.xml && \
    echo '<?xml version="1.0" encoding="UTF-8"?><metadata><groupId>tools.jackson</groupId><artifactId>jackson-base</artifactId><version>3.0.3-SNAPSHOT</version><versioning><snapshot><localCopy>true</localCopy></snapshot><lastUpdated>20250101000000</lastUpdated><snapshotVersions><snapshotVersion><extension>pom</extension><value>3.0.3-SNAPSHOT</value><updated>20250101000000</updated></snapshotVersion></snapshotVersions></versioning></metadata>' \
        > /root/.m2/repository/tools/jackson/jackson-base/3.0.3-SNAPSHOT/maven-metadata-local.xml

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 3aa88fe97982f1fe5b28c82258e1b36444293d85 || git fetch --depth 1 origin "+refs/pull/5423/head:refs/remotes/origin/pr/5423") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download dependencies and compile (skip tests for now)
RUN mvn -B -ntp compile test-compile -DskipTests

# Reset any files modified during build so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch
RUN mvn -B -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
