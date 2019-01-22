FROM debian:latest
ENV PEARL_VERSION=1.7.2

RUN apt-get update -y && apt-get upgrade -y
# Dependencies
RUN apt-get install -y \
        coreutils curl git grep \
        locales sudo tzdata
# Optional
RUN apt-get install -y fish zsh emacs vim-nox python3 tmux

ENV LOGIN=worker \
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
    groupadd -g ${UID} ${LOGIN} && \
    useradd -u ${UID} -g ${GID} -s /bin/bash -G sudo -d ${HOME} -N ${LOGIN} && \
    chown -R ${UID}:${GID} ${HOME} &&\
    echo "$LOGIN ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${LOGIN}

USER worker

RUN curl -L https://raw.githubusercontent.com/pearl-core/installer/master/install.sh | bash

RUN ln -sf ${HOME}/.config/pearl/pearl.conf ${HOME}/pearl.conf && \
    echo 'PEARL_REPOS+=("https://github.com/linkseed/pearl-repo.git")' >> ${HOME}/pearl.conf && \
    echo 'PEARL_PACKAGES["testpkg"]="${HOME}/tmp"' >> ${HOME}/pearl.conf

RUN mkdir ${HOME}/tmp
VOLUME ["${HOME}/tmp"]
WORKDIR ${HOME}

CMD ["bash"]
