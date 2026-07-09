ARG BASE_IMAGE=ubuntu:24.04
ARG CUDA_BASE

# Stage 1: builder — compile SDR software, discard after build
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai

COPY ubuntu-desktop/docker_config /docker_config/

RUN --mount=type=bind,from=ccache-host,source=/,target=/root/.ccache,rw \
    bash /docker_config/build_sdr.sh

# Stage 2: runtime — minimal image with only what's needed to run
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

COPY --from=builder /docker_config/runtime-deps.txt /tmp/runtime-deps.txt

RUN apt-get update && apt-get install -y --no-install-recommends \
        locales \
        tzdata \
        ca-certificates \
        sudo \
        vim \
        gnupg2 \
        wget \
        curl \
        zip \
        lsb-release \
        bash-completion \
        net-tools \
        iputils-ping \
        mesa-utils \
        software-properties-common \
        build-essential \
        python3 \
        python3-pip \
        python3-numpy \
        openssh-server \
        openssl \
        git \
        git-lfs \
        tmux \
        xfce4 \
        terminator \
        adwaita-icon-theme-full \
        elementary-xfce-icon-theme \
        xfce4-whiskermenu-plugin \
        fonts-wqy-zenhei \
        pulseaudio \
        ffmpeg \
        dbus-x11 \
        chrony \
        cmake \
        pkgconf \
        htop \
        nano \
        libhamlib-utils \
        libqt5svg5 \
        qt5-image-formats-plugins \
        $(cat /tmp/runtime-deps.txt) \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get remove -y --purge xfce4-screensaver \
    && userdel ubuntu || true \
    && rm -rf /tmp/runtime-deps.txt /var/lib/apt/lists/*

COPY --from=builder /usr/local /usr/local
COPY --from=builder /docker_config /docker_config

RUN ldconfig && bash /docker_config/install_sdr.sh

RUN mkdir /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    sed -i 's/required\s*pam_loginuid.so/optional pam_loginuid.so/g' /etc/pam.d/common-session && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

RUN rm -rf /usr/share/doc/* /usr/share/man/* /tmp/*

EXPOSE 22 4000
VOLUME /var/lib/docker

ENTRYPOINT ["/docker_config/entrypoint.sh"]
