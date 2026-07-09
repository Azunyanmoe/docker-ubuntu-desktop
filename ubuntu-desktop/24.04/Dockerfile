ARG BASE_IMAGE=ubuntu:24.04
ARG CUDA_BASE

FROM ${CUDA_BASE:-$BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    USER=user \
    UID=1000 \
    GID=1000 \
    PASSWORD=123456 \
    REMOTE_DESKTOP=nomachine \
    DISABLE_HTTPS=true

# Basic system setup
RUN apt-get update && apt-get install -y --no-install-recommends \
        locales \
        tzdata \
        ca-certificates \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# Pre-install basic tools
COPY ubuntu-desktop/docker_config /docker_config/
RUN bash /docker_config/pre_install.sh && rm -rf /var/lib/apt/lists/*

# Xfce4 desktop environment + dev tools (merged into one RUN to save layer size)
RUN apt-get update && apt-get install -y --no-install-recommends \
        xfce4 \
        terminator \
        fonts-wqy-zenhei \
        pulseaudio \
        ffmpeg \
        dbus-x11 \
        cmake \
        pkgconf \
        htop \
        nano \
    && apt-get remove -y --purge xfce4-screensaver \
    && userdel ubuntu || true \
    && rm -rf /var/lib/apt/lists/*

# Post-install: SDR apps, Chromium, remote desktops
RUN --mount=type=bind,from=ccache-host,source=/,target=/root/.ccache,rw \
    bash /docker_config/post_install.sh

# SSH configuration
RUN mkdir /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    sed -i 's/required\s*pam_loginuid.so/optional pam_loginuid.so/g' /etc/pam.d/common-session && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

EXPOSE 22 4000
VOLUME /var/lib/docker

ENTRYPOINT ["/docker_config/entrypoint.sh"]
