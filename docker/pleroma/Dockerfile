FROM elixir:1.6-alpine

ENV MIX_ENV prod

ARG PLEROMA_VER=develop

RUN true \
    && apk add --no-cache \
       build-base \
       dumb-init \
       git \
       postgresql-client \
       sudp \
    && addgroup pleroma \
    && adduser -h /srv/pleroma -s /bin/sh -D -G pleroma pleroma \
    && true

USER pleroma
WORKDIR /srv/pleroma

RUN true \
    && git clone https://git.pleroma.social/pleroma/pleroma.git /srv/pleroma \
    && git checkout ${PLEROMA_VER} \
    && cd /srv/pleroma \
    && git rev-parse HEAD > /srv/pleroma/REVISION \
    && rm /srv/pleroma/config/prod.secret.exs \
    && ln -s /run/secrets/prod.secret.exs /srv/pleroma/config/prod.secret.exs \
    && mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && mkdir /srv/pleroma/uploads \
    && true

COPY ["entrypoint.sh", "/usr/local/bin/entrypoint.sh"]

VOLUME /srv/pleroma/uploads/

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/entrypoint.sh"]
