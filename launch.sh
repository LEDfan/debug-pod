#!/usr/bin/env bash

set -e # fail on first error
set -u # fail on unbound (i.e. undefined) variables
set -o pipefail # fail if any command in a pipeline fail

ns=${1:-default}

kubectl apply -n "$ns" -f pod.yaml
kubectl wait --timeout=600s --for=condition=ready pod -n "$ns" debug-pod
kubectl exec -it -n "$ns" debug-pod -- /bin/bash
