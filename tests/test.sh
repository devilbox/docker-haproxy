#!/usr/bin/env bash

set -e
set -u
set -o pipefail

IMAGE="${1}"

docker run --rm --entrypoint=haproxy "${IMAGE}" -v | grep -E 'version\s+1[.0-9]+'
