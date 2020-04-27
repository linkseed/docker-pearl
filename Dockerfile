FROM linkseed/debian-base:latest
ENV PEARL_VERSION=${VER:-2.3.3}

# Dependencies
RUN sudo apt-get update -y && sudo apt-get install -y \
        python3 python3-pip bash git \
        coreutils grep sed \
        curl
# Optional
RUN sudo apt-get install -y fish zsh emacs vim-nox tmux

# Cleanup
RUN sudo apt-get autoremove -y && sudo apt-get clean -y && \
    sudo rm -rf /var/lib/apt/lists/*

# Install
COPY --chown=${UID}:${GID} ./pearl.conf ${HOME}/pearl.conf

RUN cp /etc/skel/.profile ${HOME}/ && \
    pip3 install --user pearl==${PEARL_VERSION} && \
    ${HOME}/.local/bin/pearl init && \
    mv ${HOME}/.config/pearl/pearl.conf \
       ${HOME}/.config/pearl/pearl.conf.backup && \
    ln -sf ${HOME}/pearl.conf ${HOME}/.config/pearl/pearl.conf

VOLUME ["${HOME}/tmp"]
WORKDIR ${HOME}/tmp

CMD ["bash", "-l"]
