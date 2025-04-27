FROM debian:latest

RUN apt update && \
    apt upgrade -y && \
    apt install --no-install-recommends -y \
        git \
        sudo \
        curl \
        ca-certificates \
        gpg


RUN curl -fsSL https://archive.raspberrypi.com/debian/raspberrypi.gpg.key \
  | gpg --dearmor > /usr/share/keyrings/raspberrypi-archive-keyring.gpg

ENV USER=imagegen
RUN useradd -u 4000 -ms /bin/bash "$USER" \
    && echo "${USER}:${USER}" | chpasswd \
    && adduser ${USER} sudo \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER}

WORKDIR /home/${USER}

ARG RPIIG_GIT_SHA=ba410bccd3f690a49cb8ec7a724cb59d08a4257e
RUN git clone https://github.com/raspberrypi/rpi-image-gen.git && cd rpi-image-gen && git checkout ${RPIIG_GIT_SHA}
RUN sudo chown -R imagegen:imagegen /home/imagegen/rpi-image-gen/

WORKDIR /home/${USER}/rpi-image-gen

RUN chmod +x install_deps.sh && ./install_deps.sh

USER ${USER}


ADD ./parameters /home/${USER}/rpi-image-gen/parameters
