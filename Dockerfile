FROM ruby:3.3.3-alpine3.20

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk upgrade --no-cache
RUN apk add --update --no-cache \
  aws-cli \
  bash \
  bind-tools \
  binutils \
  build-base \
  curl \
  curl-dev \
  font-bitstream-type1 \
  gettext \
  git \
  gnupg \
  graphviz \
  groff \
  jq \
  make \
  nano \
  openssh-client \
  py3-pip \
  python3-dev \
  shadow \
  sudo \
  tree \
  unzip \
  wget \
  yq

RUN ln -sf python3 /usr/bin/python

# dojo helper script
ENV DOJO_VERSION=0.13.0
RUN git clone --depth 1 -b ${DOJO_VERSION} \
  https://github.com/kudulab/dojo.git /tmp/dojo_git && \
  /tmp/dojo_git/image_scripts/src/install.sh && \
  rm -r /tmp/dojo_git

# dojo user
COPY image/bashrc /home/dojo/.bashrc
COPY image/profile /home/dojo/.profile
RUN chown dojo:dojo /home/dojo/.bashrc /home/dojo/.profile

# TODO: Use either curl or wget everywhere consistently, rather than both

# install assume-role which is a handy tool
RUN wget --tries=3 --retry-connrefused --wait=3 --random-wait \
    --quiet \
    https://github.com/remind101/assume-role/releases/download/0.3.2/assume-role-Linux && \
  chmod +x ./assume-role-Linux && \
  mv ./assume-role-Linux /usr/bin/assume-role

# Testing support
RUN gem install inspec inspec-bin test-kitchen kitchen-terraform

COPY image/etc_dojo.d/scripts/* /etc/dojo.d/scripts/
COPY image/inputrc /etc/inputrc


# bats for testing shell commands
ENV BATS_CORE_VERSION=1.11.0
ENV BATS_HELPER_DIR=/opt

RUN cd /tmp && \
  git clone --depth 1 -b v${BATS_CORE_VERSION} https://github.com/bats-core/bats-core.git && \
  cd bats-core && \
  ./install.sh ${BATS_HELPER_DIR} && \
  rm -r /tmp/bats-core && \
  ln -s /opt/bin/bats /usr/bin/bats

ENV BATS_SUPPORT_VERSION=0.3.0
RUN git clone -b v${BATS_SUPPORT_VERSION} https://github.com/bats-core/bats-support.git ${BATS_HELPER_DIR}/bats-support

ENV BATS_ASSERT_VERSION=2.1.0
RUN git clone -b v${BATS_ASSERT_VERSION} https://github.com/bats-core/bats-assert.git ${BATS_HELPER_DIR}/bats-assert

# steampipe
RUN /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"
RUN /bin/su - dojo -c '/usr/local/bin/steampipe plugin install steampipe aws terraform github docker'

# Just for debugging
RUN addgroup sudo
RUN echo 'dojo:$1$IbdSg3K9$L3cVy0i00L6Jjr3G2cdr00' | chpasswd -e
RUN echo '%sudo ALL=(ALL) ALL' > /etc/sudoers.d/sudo
RUN adduser dojo sudo

# tflint
RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# terragrunt
# Get the version so the layer won't be cached when it changes
RUN curl -sL https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .tag_name|sed 's/v//'
RUN export TERRAGRUNT_VERSION=$(curl -sL https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .tag_name|sed 's/v//') ; \
  wget \
    --quiet \
    -O /usr/local/bin/terragrunt \
    https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
    chmod 0755 /usr/local/bin/terragrunt

# terraform
# Get the version so the layer won't be cached when it changes
RUN curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions | keys | map(select(. | test("alpha") | not)) | last'
RUN export TERRAFORM_VERSION=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions | keys | map(select(. | test("alpha") | not)) | last') ; \
  wget \
      --quiet \
        https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    wget --quiet \
      -O terraform_${TERRAFORM_VERSION}_SHA256SUMS \
      https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    grep linux_amd64 terraform_${TERRAFORM_VERSION}_SHA256SUMS \
      > mySHA256SUM.txt && \
    sha256sum -cs mySHA256SUM.txt && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

COPY image/terraformrc /home/dojo/.terraformrc
COPY image/terraform-providers.tf /home/dojo/
RUN mkdir -p /home/dojo/.terraform.d/plugin-cache && \
    chown -R dojo:dojo /home/dojo/.terraformrc /home/dojo/terraform-providers.tf /home/dojo/.terraform.d
RUN /bin/su - dojo -c '/usr/local/bin/terraform -chdir=/home/dojo init -backend=false'

# Self tests
RUN mkdir -p /opt/spin-dojo/test
COPY test/self/ /opt/spin-dojo/test/

ARG EXTERNAL_VERSION_NUMBER not_set
ENV SPIN_DOJO_BASE_VERSION=$EXTERNAL_VERSION_NUMBER
RUN echo "EXTERNAL_VERSION_NUMBER = $EXTERNAL_VERSION_NUMBER"
RUN echo "SPIN_DOJO_BASE_VERSION = $SPIN_DOJO_BASE_VERSION"

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
