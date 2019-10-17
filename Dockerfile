FROM node:latest

# Install misc packages including minimal runtime used for executing non GUI Java programs
RUN apt-get update && \
    apt-get clean && \
    apt-get -qqy --no-install-recommends -y install \
    xvfb \
    xdotool \
    ffmpeg \
    openbox \
    dbus \
    dbus-x11 \
    sudo

# Directory cleanup
RUN mkdir -p /var/run/dbus
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Install Chrome
RUN apt-get update && apt-get -y install chromium
RUN mkdir /etc/chromium /etc/chromium/policies /etc/chromium/policies/managed /etc/chromium/policies/recommended

# Add normal user with passwordless sudo
RUN useradd glados --shell /bin/bash --create-home
RUN chown glados:glados /home/glados

# Switch to glados user and run initial setup
USER glados
ENV PATH="/home/glados/bin:${PATH}"

# Switch to root user
USER root

# Copy information
WORKDIR /home/glados/.internal
COPY . .

# Install deps & build
RUN yarn && yarn build

# Cleanup
RUN rm -rf src

# Chromium Policies
COPY ./configs/chromium_policy.json /etc/chromium/policies/managed/policies.json

ENTRYPOINT [ "yarn", "start" ]
