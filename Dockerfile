FROM ghcr.io/runatlantis/atlantis:v0.35.0

ARG TERRAGRUNT_VERSION=v0.83.2

ADD ["https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64", "/usr/local/bin/terragrunt"]
ADD ["https://get.opentofu.org/install-opentofu.sh", "install-opentofu.sh"]

USER root

RUN chmod 755 /usr/local/bin/terragrunt && \
        apk update

RUN apk add --no-cache py3-pip

RUN pip install --no-cache-dir checkov==3.2.451 --break-system-packages

RUN chmod u+x install-opentofu.sh && \
        ./install-opentofu.sh --install-method apk && \
        rm -f install-opentofu.sh /usr/local/bin/terraform

USER atlantis
ENTRYPOINT ["/usr/local/bin/atlantis"]
CMD ["--version"]
