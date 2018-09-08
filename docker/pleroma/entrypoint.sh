#!/bin/sh

set -eu

# Must match what is set in Dockerfile
PLEROMA_USER=pleroma

# Find the pleroma user's home directory
PLEROMA_HOME=$(getent passwd plereoma | cut -d: -f6)
if test -z "${PLEROMA_HOME}"; then
    echo "Could not determine home directory for user 'pleroma'"
    exit 1
elif ! test -d "${PLEROMA_HOME}"; then
    echo "pleroma user home directory '${PLEROMA_HOME}' does not exist"
    exit 1
else
    echo "Set \$PLEROMA_HOME to ${PLEROMA_HOME}"
fi

# As root, use the Postgres superuser pgpass file to configure the database.
# In Swarm mode, pass in superuser.pgpass and setup_db.psql as Swarm secrets.
# Outside of Swarm mode, you can still mount those files as volumes.
# superuser.pgpass should be a normal .pgpass file
# setup_db.psql should be Pleroma's setup_db.psql file from 'mix generate_config'
PGPASSFILE="/run/secrets/superuser.pgpass" psql --file="/run/secrets/setup_db.psql"

# Since we pass --preserve-env to sudo below, try to at least set $HOME correctly
HOME="${PLEROMA_HOME}"

# As the pleroma user, run mix phx.server
# Note that this builds the configuration from prod.secret.exs into the running application;
# you cannot reconfigure the server by changing prod.secret.exs without restarting the container.
# Note that /run/secrets/prod.secret.exs is symlinked to ${PLEROMA_HOME}/config/prod.secret.exs,
# and that this file should be generated from 'mix generate_config'.
cd "${HOME}"
exec sudo --preserve-env --user=pleroma mix phx.server
