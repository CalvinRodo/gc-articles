FROM mcr.microsoft.com/vscode/devcontainers/base:buster@sha256:8d456a2cb95396fcc5395e18fa50df9b4f525da496f772e968ca4a8467de53af

ARG USERNAME=vscode

# Set these in devcontainer.json
ARG TERRAFORM_VERSION
ARG TERRAFORM_CHECKSUM
ARG TERRAGRUNT_VERSION
ARG TERRAGRUNT_CHECKSUM

# Install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends awscli build-essential ca-certificates curl git gnupg2 jq libffi-dev make openssh-client python3-dev python3-pip vim zsh \
    && apt-get autoremove -y && apt-get clean -y 

# Install Terraform
RUN curl -Lo terraform.zip https://releases.hashicorp.com/terraform/"${TERRAFORM_VERSION}"/terraform_"${TERRAFORM_VERSION}"_linux_"$(dpkg --print-architecture)".zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# Install Terragrunt
RUN curl -Lo terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v"${TERRAGRUNT_VERSION}"/terragrunt_linux_"$(dpkg --print-architecture)" \
    && chmod +x terragrunt \
    && mv terragrunt /usr/local/bin/

# Setup aliases and autocomplete
RUN echo "\n\
complete -C /usr/bin/aws_completer aws\n\
complete -C /usr/local/bin/terraform terraform\n\
complete -C /usr/local/bin/terraform terragrunt\n\
alias tf='terraform'\n\
alias tg='terragrunt'\n\
alias ll='la -la'" >> /home/"${USERNAME}"/.zshrc