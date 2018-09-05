FROM elixir:1.6-alpine

ENV MIX_ENV dev

ARG PLEROMA_VER=develop

RUN true \
    && apk add --no-cache \
       build-base \
       dumb-init \
       git \
       postgresql-client \
    && addgroup pleroma \
    && adduser -h /pleroma -s /bin/sh -D -G pleroma pleroma \
    && true

USER pleroma
WORKDIR /pleroma

RUN true \
    && git https://git.pleroma.social/pleroma/pleroma.git /pleroma \
    && git checkout ${PLEROMA_VER} \
    && rm /pleroma/config/prod.secret.exs \
    && ln -s /run/secrets/prod.secret.exs /pleroma/config/prod.secret.exs \
    && mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && mkdir /pleroma/uploads \
    && true

COPY ["entrypoint.sh", "/usr/local/bin/entrypoint.sh"]

VOLUME /pleroma/uploads/

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/entrypoint.sh"]
