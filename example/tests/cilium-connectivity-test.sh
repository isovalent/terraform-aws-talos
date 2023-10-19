#!/bin/bash

set -euxo pipefail

# Grab the path to the kubeconfig file.
export KUBECONFIG=$(terraform output --raw path_to_kubeconfig_file)

# Run the connectivity tests.
kubectl -n kube-system port-forward svc/hubble-relay 4245:80 &
# NS precreation is required because of https://www.talos.dev/v1.5/kubernetes-guides/configuration/pod-security/
kubectl create ns cilium-test
kubectl label ns cilium-test pod-security.kubernetes.io/enforce=privileged
kubectl label ns cilium-test pod-security.kubernetes.io/warn=privileged
PID=$!
set +e
cilium connectivity test
set -e
kill -9 "${PID}"
kubectl delete ns cilium-test