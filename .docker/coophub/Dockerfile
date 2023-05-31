ARG version_elixir

FROM elixir:${version_elixir}
ARG version_node
ARG host_uid
ARG host_gid
ENV VERSION_NODE=${version_node}

RUN apt-get update \
    && apt-get install -y \
        git

RUN usermod --non-unique --uid ${host_uid} www-data \
    && groupmod --non-unique --gid ${host_gid} www-data

# Install node
ENV NVM_DIR=/opt/nvm
RUN git clone https://github.com/nvm-sh/nvm.git $NVM_DIR
RUN cd $NVM_DIR && \
    git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)` && \
    . $NVM_DIR/nvm.sh && \
    nvm install ${VERSION_NODE} && \
    nvm use node && \
    npm install --global npm@8 && \
    npm install --global webpack && \
    npm install --global webpack-cli
RUN echo "source ${NVM_DIR}/nvm.sh" > $HOME/.bashrc

WORKDIR /coophub
COPY *.sh /usr/local/bin/
ENTRYPOINT [ "bash", "/usr/local/bin/entrypoint.sh" ]
