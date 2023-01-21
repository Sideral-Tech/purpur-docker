FROM ghcr.io/supportpal/github-gh-cli as semeru

ARG GH_TOKEN
ENV GH_TOKEN=${GH_TOKEN}

WORKDIR /app

RUN gh release download --pattern "ibm-semeru-open-jdk_aarch64_linux_*.tar.gz" --repo ibmruntimes/semeru17-binaries
RUN mkdir openjdk
RUN tar -xzf ibm-semeru-open-jdk_aarch64_linux_*.tar.gz -C openjdk --strip-components=1

FROM ubuntu:latest

ENV UNAME=purpur
ENV UID=1000
ENV GID=1000
ENV JAVA_HOME=/opt/java/openjdk
ENV JVM_SETTINGS="-Xoptionsfile=/app/server/config.jvm"
ENV MC_VERSION=1.19.3

WORKDIR /app
RUN apt update && apt install -y wget
RUN mkdir -p /app/server/cache/jvm
RUN wget https://api.purpurmc.org/v2/purpur/${MC_VERSION}/latest/download -O ./server/purpur.jar

COPY ./config.jvm /app/server/config.jvm

RUN groupadd -g ${GID} ${UNAME} \
    && useradd -r -u ${UID} -g ${UNAME} ${UNAME} \
    && chown -R ${UNAME}:${UNAME} /app/server \
    && echo "eula=true" > /app/server/eula.txt

COPY --from=semeru /app/opejdk /opt/java

ENV PATH="${JAVA_HOME}/bin:${PATH}"

EXPOSE 25565

USER ${UNAME}

ENTRYPOINT ["java", "--add-modules=jdk.incubator.vector", ${JVM_SETTINGS}}, "-jar", "/app/purpur.jar", "nogui"]
