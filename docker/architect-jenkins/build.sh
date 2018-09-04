#!/bin/sh
set -eu

cmd=$(basename "$0")
dir=$(dirname "$0")

version=$(cat "$dir/VERSION")
repo="mrled"
name="architect-jenkins"
fulltag="${repo}/${name}:${version}"

usage() {
    cat <<ENDUSAGE
Usage: $cmd < -h | buildpush | repotags >
Build and deploy the architect-jenkins Docker container

ARGUMENTS
    -h | --help:        Print help and exit
    buildpush:          Build the Docker container and push to remote repo
    repotags:           Show all tags in the remote repo

NOTE:   Set the container version in the VERSION file first
        At this time, based on the contents of VERSION, the tag would be:

        $fulltag

ENDUSAGE
}

if test $# = 0; then
    usage
    exit 1
fi

case "$1" in
    -h | --help )
        usage
        exit 0
        ;;
    buildpush )
        docker build "$dir" --tag "$fulltag"
        docker push "$fulltag"
        exit 0
        ;;
    repotags )
        curl --silent "https://registry.hub.docker.com/v1/repositories/$repo/$name/tags" | jq -r '.[].name'
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
esac
