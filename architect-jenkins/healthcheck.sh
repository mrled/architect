#!/bin/sh
set -e

curlargs=""
if ! "$HEALTHCHECK_VERIFY_TLS"; then
    curlargs="-k"
fi

# According to the Docker HEALTHCHECK documentation at
# https://docs.docker.com/engine/reference/builder/#healthcheck
# the healthcheck should return only zero or one,
# but curl has other return values when it fails
curl $curlargs "$HEALTHCHECK_URL" || exit 1
