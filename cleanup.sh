#!/usr/bin/env bash

set -e # fail on first error
set -u # fail on unbound (i.e. undefined) variables
set -o pipefail # fail if any command in a pipeline fail

ns=${1:-default}

echo $ns

kubectl delete -n "$ns" pod/debug-pod || true
