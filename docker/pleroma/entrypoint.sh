#!/bin/sh

set -eu

PGPASSFILE="/run/secrets/superuser.pgpass" psql --file="/run/secrets/setup_db.psql"

# TODO: preserve environment except for $HOME variable
su - pleroma
cd /pleroma
mix phx.server
