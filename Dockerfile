FROM google/cloud-sdk:alpine

ARG KUBE_BINARY_URL="https://dl.k8s.io/release/v1.27.3/bin/linux/amd64"

LABEL version="1.5.3"
RUN apk add --update py-pip
RUN apk add --no-cache \
    bash \
    curl \
    gettext \
    jq \
    git \
    openssh-client \
    openssl \
    py-pip

# install docker
COPY --from=docker:18 /usr/local/bin/docker* /usr/local/bin/

RUN pip install --upgrade pip

# install docker-compose
RUN apk add --no-cache --virtual build-deps \
    gcc \
    python3-dev \
    libffi-dev \
    openssl-dev \
    libc-dev \
    make \
    && pip install docker-compose \
    && apk del build-deps

RUN curl -sSL https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash; \
    helm init --client-only

# configure gcloud git helper for CSR usage
RUN git config --global credential.helper gcloud.sh

# 
RUN gcloud components install gke-gcloud-auth-plugin

# Install cfssl and cfssljson
RUN curl -sSL https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 > /usr/bin/cfssl \
    && curl -sSL https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 > /usr/bin/cfssljson \
    && chmod +x /usr/bin/cfssl /usr/bin/cfssljson

RUN curl -sSL https://github.com/roboll/helmfile/releases/download/v0.81.3/helmfile_linux_amd64 -o /usr/bin/helmfile \
    && chmod +x /usr/bin/helmfile

RUN helm plugin install https://github.com/databus23/helm-diff --version v2.11.0+5

# Install kubectl and kubeadm
RUN curl -sSL ${KUBE_BINARY_URL}/kubectl -o /usr/bin/kubectl \
    && curl -sSL ${KUBE_BINARY_URL}/kubeadm -o /usr/bin/kubeadm \
    && chmod +x /usr/bin/kubectl /usr/bin/kubeadm

