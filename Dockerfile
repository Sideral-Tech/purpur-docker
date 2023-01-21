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

WORKDIR /app

RUN apt update \
    && apt install -y wget \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /app/config/ \
    && mkdir -p /app/server/plugins \
    && groupadd -g ${GID} ${UNAME} \
    && useradd -r -u ${UID} -g ${UNAME} ${UNAME} \
    && chown -R ${UNAME}:${UNAME} /app/server

COPY ./contents/config/config.jvm /app/config/config.jvm
COPY ./contents/scripts/run.sh /app/run.sh

COPY --from=semeru /app/openjdk /opt/java/openjdk

ENV PATH="${JAVA_HOME}/bin:${PATH}"

EXPOSE 25565
EXPOSE 19132

USER ${UNAME}

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
