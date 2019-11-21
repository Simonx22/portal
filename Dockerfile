FROM node:lts-buster

# Add Google Chrome repositories
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list
# Install Google Chrome, audio and other misc packages including minimal runtime used for executing non GUI Java programs

# Install Chromium, audio and other misc packages, cleanup, create Chromium policies folders, workarounds
RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get --no-install-recommends -y install \
        dbus \
        dbus-x11 \
        xvfb \
        xdotool \
        openbox \
        fonts-opensymbol \
        fonts-symbola \
        fonts-liberation \
        fonts-freefont-ttf \
        fonts-droid-fallback \
        fonts-dejavu-core \
        fonts-arphic-ukai \
        fonts-arphic-uming \
        fonts-ipafont-mincho \
        fonts-ipafont-gothic \
        fonts-unfonts-core \
        fonts-noto-color-emoji \
        fonts-noto \
        fonts-nanum \
        pulseaudio \
        x11-session-utils \
        ffmpeg \
        sudo \
        grep \
        procps \
        google-chrome-stable \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && mkdir -p /var/run/dbus \
    && mkdir -p /etc/opt/chrome/policies/managed /etc/opt/chrome/policies/recommended \
    && mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && chown root /tmp/.X11-unix

# Add normal user
RUN useradd glados --shell /bin/bash --create-home && usermod -a -G audio glados

# Copy information
WORKDIR /home/glados/.internal
COPY . .

# Chromium Policies
COPY ./configs/chromium_policy.json /etc/opt/chrome/policies/managed/policies.json
# Chromium Preferences
COPY ./configs/master_preferences.json /etc/opt/chrome/master_preferences
# Pulseaudio Configuration
COPY ./configs/pulse_config.pa /tmp/pulse_config.pa
# Openbox Configuration
COPY ./configs/openbox_config.xml /var/lib/openbox/openbox_config.xml

# Install deps, build then cleanup
RUN yarn && yarn build && yarn cache clean && rm -rf src

ENTRYPOINT [ "bash", "./start.sh" ]
