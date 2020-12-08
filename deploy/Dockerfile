FROM alpine:3.12

LABEL maintainer="OmiseGO Team <omg@omise.co>"
LABEL description="Deploy image for OmiseGO eWallet"

RUN set -xe \
 && apk add --update --no-cache --virtual .utils \
        bash \
        ca-certificates \
        curl \
        git \
        gnupg \
        libressl \
        libressl-dev \
        openssh-client

ARG CLOUD_SDK_VERSION=255.0.0
ARG CLOUD_SDK_DOWNLOAD_SHA256="18fcbc81b3b095ff5ef92fd41286a045f782c18d99a976c0621140a8fde3fbad"

RUN set -xe \
 && apk add --update --no-cache --virtual .gcloud-runtime \
        python2 \
        py-crcmod \
        libc6-compat \
 && CLOUD_SDK_DOWNLOAD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz" \
 && curl -fsL -o cloud-sdk-src.tar.gz "${CLOUD_SDK_DOWNLOAD_URL}" \
 && echo "${CLOUD_SDK_DOWNLOAD_SHA256}  cloud-sdk-src.tar.gz" |sha256sum -c - \
 && tar xzf cloud-sdk-src.tar.gz \
 && tar -xzC /usr/local --strip-components=1 -f cloud-sdk-src.tar.gz \
 && rm cloud-sdk-src.tar.gz \
 && ln -s /lib /lib64 \
 && gcloud components install kubectl \
 && gcloud config set core/disable_usage_reporting true \
 && gcloud config set component_manager/disable_update_check true \
 && gcloud config set metrics/environment github_docker_image \
 && gcloud --version

ARG KAPITAN_VERSION="0.22.3"

RUN apk add --update --no-cache --virtual .kapitan-runtime \
        libffi \
        libstdc++ \
        python3 \
 && apk add --update --no-cache --virtual .kapitan-build \
        build-base \
        libffi-dev \
        python3-dev \
 && python3 -m ensurepip \
 && pip3 install --upgrade pip \
 && pip3 install kapitan==${KAPITAN_VERSION} \
 && apk del .kapitan-build \
 && kapitan --version

ARG HELM_VERSION="2.14.2"
ARG HELM_DOWNLOAD_SHA256="9f50e69cf5cfa7268b28686728ad0227507a169e52bf59c99ada872ddd9679f0"

RUN set -xe \
 && HELM_DOWNLOAD_URL="https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
 && curl -fsL -o helm-src.tar.gz "${HELM_DOWNLOAD_URL}" \
 && echo "${HELM_DOWNLOAD_SHA256}  helm-src.tar.gz" |sha256sum -c - \
 && tar xzf helm-src.tar.gz \
 && mkdir -p /usr/src/helm \
 && tar -xzC /usr/src/helm --strip-components=1 -f helm-src.tar.gz \
 && install -m0755 /usr/src/helm/helm /usr/local/bin/helm \
 && install -m0755 /usr/src/helm/tiller /usr/local/bin/tiller \
 && rm -rf /usr/src/helm \
 && rm helm-src.tar.gz \
 && helm version --client

ARG TERRAFORM_VERSION="0.12.7"
ARG TERRAFORM_DOWNLOAD_SHA256="a0fa11217325f76bf1b4f53b0f7a6efb1be1826826ef8024f2f45e60187925e7"

RUN set -xe \
 && TERRAFORM_DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
 && curl -fsL -o terraform-src.zip "${TERRAFORM_DOWNLOAD_URL}" \
 && echo "${TERRAFORM_DOWNLOAD_SHA256}  terraform-src.zip" |sha256sum -c - \
 && unzip terraform-src.zip \
 && mv terraform /usr/local/bin \
 && rm terraform-src.zip \
 && terraform version
