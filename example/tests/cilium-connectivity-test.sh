#!/bin/bash

set -euxo pipefail

# Grab the path to the kubeconfig file.
export KUBECONFIG=$(terraform output --raw path_to_kubeconfig_file)

# Run the connectivity tests.
kubectl -n kube-system port-forward svc/hubble-relay 4245:80 &
PID=$!
set +e
cilium connectivity test --force-deploy
set -e
kill -9 "${PID}"