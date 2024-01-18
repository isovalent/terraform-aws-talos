#!/bin/bash

set -euxo pipefail

ns=cilium-test

# Grab the path to the kubeconfig file.
export KUBECONFIG=$(terraform output --raw path_to_kubeconfig_file)

# Run the connectivity tests.
kubectl -n kube-system port-forward svc/hubble-relay 4245:80 &
# NS precreation is required because of https://www.talos.dev/v1.5/kubernetes-guides/configuration/pod-security/
kubectl create ns ${ns}
kubectl label ns ${ns} pod-security.kubernetes.io/enforce=privileged
kubectl label ns ${ns} pod-security.kubernetes.io/warn=privileged
PID=$!
set +e
cilium connectivity test --test-namespace=${ns}
set -e
kill -9 "${PID}"
kubectl delete ns ${ns}
