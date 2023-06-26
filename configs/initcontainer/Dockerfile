FROM ubuntu:22.04

WORKDIR /workdir

RUN apt-get update && apt-get install -y \
    curl \
    openssl \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LO https://github.com/fullstorydev/grpcurl/releases/download/v1.8.7/grpcurl_1.8.7_linux_x86_64.tar.gz \
    && tar -xvf grpcurl_1.8.7_linux_x86_64.tar.gz \
    && mv grpcurl /usr/local/bin/ \
    && rm grpcurl_1.8.7_linux_x86_64.tar.gz LICENSE \
    && curl -L -o /workdir/getresource.proto https://raw.githubusercontent.com/confidential-containers/attestation-agent/main/protos/getresource.proto

COPY scripts/decrypt-folder.sh /workdir/decrypt-folder.sh
COPY initcontainer/init-container-script.sh /workdir/init-container-script.sh

ENTRYPOINT [ "/workdir/init-container-script.sh" ]
