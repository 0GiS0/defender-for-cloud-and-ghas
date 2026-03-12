ARG NODE_IMAGE=node:20-bullseye
ARG TERRAFORM_VERSION=1.8.5

FROM ${NODE_IMAGE} AS node

FROM mcr.microsoft.com/devcontainers/dotnet:0-6.0

ARG TERRAFORM_VERSION

COPY --from=node /usr/local/ /usr/local/

RUN rm -f /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarn.list.save \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl unzip \
    && arch="$(dpkg --print-architecture)" \
    && case "$arch" in \
        amd64) terraform_arch="amd64" ;; \
        arm64) terraform_arch="arm64" ;; \
        *) echo "Unsupported architecture: $arch"; exit 1 ;; \
    esac \
    && curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${terraform_arch}.zip" -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && rm -f /tmp/terraform.zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && terraform version \
    && node --version \
    && npm --version