FROM mcr.microsoft.com/devcontainers/universal:2

ARG FLUTTER_VERSION="3.10.2"

RUN git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION} --depth 1 /flutter
RUN chmod -R 777 /flutter
RUN git config --system --add safe.directory /flutter
RUN echo 'export PATH=$PATH:/flutter/bin' >> /etc/bash.bashrc
