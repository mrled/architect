#!/bin/sh

set -eu

# Ensure the jenkins user is in a group with the same GID as the hosts's 'docker' group
# If /var/run/docker.sock is mounted in this container,
# this will allow Jenkins to create new containers on the host for build slaves

echo "Passed value '${DOCKER_HOST_DOCKER_GID}' for the Docker host's 'docker' group'"
echo "Ensuring in-container jenkins user '${JENKINS_USER}' is a member of a group with that GID..."

GETENT_RESULT=$(getent group "${DOCKER_HOST_DOCKER_GID}" | cut -d: -f1)
if test -z "$GETENT_RESULT"; then
    GROUP_NAME="hostdocker"
    echo "No group exists in container with GID '${DOCKER_HOST_DOCKER_GID}'"
    echo "Creating new group '${GROUP_NAME}' with GID '${DOCKER_HOST_DOCKER_GID}'"
    addgroup -g "${DOCKER_HOST_DOCKER_GID}" "${GROUP_NAME}"
else
    echo "Group with name '${GETENT_RESULT}' already exists with GID '${DOCKER_HOST_DOCKER_GID}'"
    GROUP_NAME="${GETENT_RESULT}"
fi

echo "Ensuring '${JENKINS_USER}' is in group '${GROUP_NAME}'"
usermod --append --groups "${GROUP_NAME}" "${JENKINS_USER}"

# Since we pass --preserve-env to sudo below,
# try to at least set $HOME correctly
HOME=$(getent passwd "${JENKINS_USER}" | cut -d: -f6)
if test -z "${HOME}"; then
    echo "Could not determine home directory for '${JENKINS_USER}'"
    exit 1
elif ! test -d "${HOME}"; then
    echo "Jenkins user home directory '${HOME}' does not exist"
    exit 1
else
    echo "Set \$HOME to ${HOME}"
fi

# Clean up our error settings
# (Unclear whether jenkins.sh will fail if these are set)
set +eu

exec sudo --preserve-env --user="${JENKINS_USER}" /usr/local/bin/jenkins.sh "$@"
