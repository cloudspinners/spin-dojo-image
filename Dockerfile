FROM ruby:3.1.2-alpine3.16

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk add --update --no-cache \
bash \
  binutils \
  build-base \
  curl \
  curl \
  curl-dev \
  font-bitstream-type1 \
  gettext \
  git \
  gnupg \
  graphviz \
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
ENV DOJO_VERSION=0.11.0
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

# So we can run inspec tests
RUN gem install inspec inspec-bin

COPY image/etc_dojo.d/scripts/* /etc/dojo.d/scripts/
COPY image/inputrc /etc/inputrc


# bats for testing shell commands
ENV BATS_CORE_VERSION=1.7.0
ENV BATS_HELPER_DIR=/opt

RUN cd /tmp && \
  git clone --depth 1 -b v${BATS_CORE_VERSION} https://github.com/bats-core/bats-core.git && \
  cd bats-core && \
  ./install.sh ${BATS_HELPER_DIR} && \
  rm -r /tmp/bats-core && \
  ln -s /opt/bin/bats /usr/bin/bats

ENV BATS_SUPPORT_VERSION=0.3.0
RUN git clone -b v${BATS_SUPPORT_VERSION} https://github.com/bats-core/bats-support.git ${BATS_HELPER_DIR}/bats-support

ENV BATS_ASSERT_VERSION=2.0.0
RUN git clone -b v${BATS_ASSERT_VERSION} https://github.com/bats-core/bats-assert.git ${BATS_HELPER_DIR}/bats-assert


# glibc (needed for awscli)

# OPTION 1: Download it. Gives symbol not found errors
# ENV GLIBC_VERSION=2.35-r0
# RUN curl -sL \
#       https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
#       -o /etc/apk/keys/sgerrand.rsa.pub && \
#     curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
#     curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
#     curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
#     apk add --no-cache \
#       glibc-${GLIBC_VERSION}.apk \
#       glibc-bin-${GLIBC_VERSION}.apk \
#       glibc-i18n-${GLIBC_VERSION}.apk && \
#     rm -f glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk

# OPTION 2: gcompat. Not compatible with awscli later than 2.1.39
RUN apk add gcompat

# OPTION 3: Build my own using https://github.com/sgerrand/docker-glibc-builder. Takes many hours to build, doesn't work.
# COPY image/glibc-aarch64-2.35-bin.tar.gz /tmp/
# RUN tar xzf /tmp/glibc-aarch64-2.35-bin.tar.gz -C /
# RUN rm /tmp/glibc-aarch64-2.35-bin.tar.gz

# awscli
# ENV AWS_CLI_VERSION=2.7.12
ENV AWS_CLI_VERSION=2.1.39
# ENV AWS_CLI_VERSION=2.2.0
ENV CPU_ARCH=x86_64
COPY image/aws.gpg /opt/aws.gpg
# TODO: Figure out how to support x86_64 and aarch64 with multi-cpu architecture support
RUN curl -sL \
    https://awscli.amazonaws.com/awscli-exe-linux-${CPU_ARCH}-${AWS_CLI_VERSION}.zip.sig \
    -o awscliv2.sig && \
  curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-${CPU_ARCH}-${AWS_CLI_VERSION}.zip" \
    -o "awscliv2.zip" && \
  gpg --import /opt/aws.gpg && \
  gpg --verify awscliv2.sig awscliv2.zip && \
  unzip -q awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2.zip
RUN uname -a
RUN aws --version

# Just for debugging
RUN addgroup sudo
RUN echo 'dojo:$1$IbdSg3K9$L3cVy0i00L6Jjr3G2cdr00' | chpasswd -e
RUN echo '%sudo ALL=(ALL) ALL' > /etc/sudoers.d/sudo
RUN adduser dojo sudo

# terraform
ENV TERRAFORM_VERSION=1.2.4
RUN wget \
    --quiet \
      https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  wget --quiet \
    -O terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
  grep linux_amd64 terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    > mySHA256SUM.txt && \
  sha256sum -cs mySHA256SUM.txt && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

COPY image/terraformrc /home/dojo/.terraformrc
COPY image/terraform-providers.tf /home/dojo/
RUN mkdir -p /home/dojo/.terraform.d/plugin-cache && \
    chown -R dojo:dojo /home/dojo/.terraformrc /home/dojo/terraform-providers.tf /home/dojo/.terraform.d
RUN /bin/su - dojo -c 'terraform -chdir=/home/dojo init -backend=false'

# Self tests
RUN mkdir -p /opt/spin-dojo/test
COPY test/self/ /opt/spin-dojo/test/

ARG EXTERNAL_VERSION_NUMBER not_set
ENV SPIN_DOJO_BASE_VERSION=$EXTERNAL_VERSION_NUMBER
RUN echo "EXTERNAL_VERSION_NUMBER = $EXTERNAL_VERSION_NUMBER"
RUN echo "SPIN_DOJO_BASE_VERSION = $SPIN_DOJO_BASE_VERSION"

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
