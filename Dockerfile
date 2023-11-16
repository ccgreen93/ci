FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:445.0.0-alpine as base

ARG terraform_version="1.5.6"
ARG terragrunt_version="0.50.13"
ARG tfsec_version="1.28.1"
ARG kubectl_version="1.25.10"

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk add  \
      bash \
      github-cli@community \
      jq \
      wget \
      yq \
      zip \
      go \
      py3-pip \
      tar \
      openssl \
      trivy@testing && \
    # Install kubectl
    wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/v${kubectl_version}/bin/linux/amd64/kubectl && \
    chmod u+x kubectl && \
    mv kubectl /usr/local/bin/ && \
    # Install terraform
    wget -O terraform_checksums https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_SHA256SUMS && \
    wget https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip && \
    cat terraform_checksums | grep terraform_${terraform_version}_linux_amd64.zip | sha256sum -c && \
    unzip terraform_${terraform_version}_linux_amd64.zip && \
    mv terraform /usr/local/bin && \
    rm terraform_${terraform_version}_linux_amd64.zip terraform_checksums && \
    # Install terragrunt
    wget -O terragrunt_checksums https://github.com/gruntwork-io/terragrunt/releases/download/v${terragrunt_version}/SHA256SUMS && \
    wget https://github.com/gruntwork-io/terragrunt/releases/download/v${terragrunt_version}/terragrunt_linux_amd64 && \
    cat terragrunt_checksums | grep terragrunt_linux_amd64 | sha256sum -c && \
    chmod u+x terragrunt_linux_amd64 && \
    mv terragrunt_linux_amd64 /usr/local/bin/terragrunt && \
    rm terragrunt_checksums && \
    # Install tfsec
    wget -O tfsec_checksums https://github.com/aquasecurity/tfsec/releases/download/v${tfsec_version}/tfsec_${tfsec_version}_checksums.txt && \
    wget https://github.com/aquasecurity/tfsec/releases/download/v${tfsec_version}/tfsec_${tfsec_version}_linux_amd64.tar.gz && \
    cat tfsec_checksums | grep tfsec_${tfsec_version}_linux_amd64.tar.gz | sha256sum -c && \
    tar -xvf tfsec_${tfsec_version}_linux_amd64.tar.gz && \
    chmod u+x tfsec && \
    mv tfsec /usr/local/bin && \
    rm tfsec_${tfsec_version}_linux_amd64.tar.gz tfsec_checksums LICENSE

RUN gcloud components install gke-gcloud-auth-plugin kustomize kpt