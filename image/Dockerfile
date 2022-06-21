FROM ruby:3.1.2-alpine3.16

ENV TERRAFORM_VERSION=1.2.3
ENV AWS_CLI_VERSION=2.7.7
ENV GLIBC_VERSION=2.31-r0
ENV DOJO_VERSION=0.11.0

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk --update add --no-cache \
  bash \
  shadow \
  sudo \
  wget \
  git \
  graphviz \
  font-bitstream-type1 \
  openssh-client \
  curl \
  curl-dev \
  make \
  jq \
  yq \
  unzip \
  gnupg \
  nano \
  binutils \
  curl \
  build-base \
  gettext

# dojo helper script
RUN git clone --depth 1 -b ${DOJO_VERSION} \
  https://github.com/kudulab/dojo.git /tmp/dojo_git && \
  /tmp/dojo_git/image_scripts/src/install.sh && \
  rm -r /tmp/dojo_git

# dojo user
COPY bashrc /home/dojo/.bashrc
COPY profile /home/dojo/.profile
RUN chown dojo:dojo /home/dojo/.bashrc /home/dojo/.profile

# install assume-role which is a handy tool
RUN wget --tries=3 --retry-connrefused --wait=3 --random-wait \
    --quiet --show-progress --progress=bar:force \
    https://github.com/remind101/assume-role/releases/download/0.3.2/assume-role-Linux && \
  chmod +x ./assume-role-Linux && \
  mv ./assume-role-Linux /usr/bin/assume-role

# terraform
RUN wget \
    --quiet --show-progress --progress=bar:force \
      https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  wget --quiet --show-progress --progress=bar:force \
    -O terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
  grep linux_amd64 terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    > mySHA256SUM.txt && \
  sha256sum -cs mySHA256SUM.txt && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# TODO: Use either curl or wget everywhere

# glibc
RUN curl -sL \
      https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
      -o /etc/apk/keys/sgerrand.rsa.pub && \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    apk add --no-cache \
      glibc-${GLIBC_VERSION}.apk \
      glibc-bin-${GLIBC_VERSION}.apk && \
    rm -f glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk

# awscli
COPY aws.gpg /opt/aws.gpg
RUN curl -sL \
    https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip.sig \
    -o awscliv2.sig && \
  curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" \
    -o "awscliv2.zip" && \
  gpg --import /opt/aws.gpg && \
  gpg --verify awscliv2.sig awscliv2.zip && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2.zip

# So we can run inspec tests
RUN gem install inspec inspec-bin

COPY terraformrc /home/dojo/.terraformrc
RUN chown dojo:dojo /home/dojo/.terraformrc

COPY etc_dojo.d/scripts/* /etc/dojo.d/scripts/
COPY inputrc /etc/inputrc

# Just for debugging
RUN addgroup sudo
RUN echo 'dojo:$1$IbdSg3K9$L3cVy0i00L6Jjr3G2cdr00' | chpasswd -e
RUN echo '%sudo ALL=(ALL) ALL' > /etc/sudoers.d/sudo
RUN adduser dojo sudo

RUN mkdir -p /home/dojo/.terraform.d/plugin-cache && \
  chown -R dojo:dojo /home/dojo/.terraform.d

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
