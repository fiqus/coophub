ARG version_elixir

FROM elixir:${version_elixir}
ARG host_uid
ARG host_gid

RUN apt-get update \
    && apt-get install -y \
        git

RUN usermod --non-unique --uid ${host_uid} www-data \
    && groupmod --non-unique --gid ${host_gid} www-data

WORKDIR /coophub
COPY *.sh /usr/local/bin/
ENTRYPOINT [ "bash", "/usr/local/bin/entrypoint.sh" ]
