FROM debian:latest
ENV PEARL_VERSION=${VER:-2.3.3}

RUN apt-get update -y && apt-get upgrade -y
# Dependencies
RUN apt-get install -y \
        python3 python3-pip \
        coreutils curl git grep \
        locales sudo tzdata
# Optional
RUN apt-get install -y fish zsh emacs vim-nox python3 tmux

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Settings
ENV USER=worker \
    HOME=/home/work \
    LANG=en_US.UTF-8 \
    UID=10001 \
    GID=10001

RUN echo "LANG=$LANG" > /etc/default/locale && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "LANG=en_US.UT-8" > /etc/default/locale && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    mkdir -p ${HOME} && \
    groupadd -g ${UID} ${USER} && \
    useradd -u ${UID} -g ${GID} -s /bin/bash -G sudo -d ${HOME} -N ${USER} && \
    chown -R ${UID}:${GID} ${HOME} &&\
    echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}

# Install
COPY ./pearl.conf ${HOME}/pearl.conf
RUN chown ${UID}:${GID} ${HOME}/pearl.conf

USER worker

RUN cp /etc/skel/.profile ${HOME}/ && \
    pip3 install --user pearl==${PEARL_VERSION} && \
    ${HOME}/.local/bin/pearl init && \
    mv ${HOME}/.config/pearl/pearl.conf ${HOME}/.config/pearl/pearl.conf.bak && \
    ln -sf ${HOME}/pearl.conf ${HOME}/.config/pearl/pearl.conf

RUN mkdir ${HOME}/tmp
VOLUME ["${HOME}/tmp"]
WORKDIR ${HOME}/tmp

CMD ["bash", "-l"]
