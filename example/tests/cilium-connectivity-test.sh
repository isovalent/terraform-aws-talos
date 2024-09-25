#!/usr/bin/env bash

set -euxo pipefail

# Grab the path to the kubeconfig file.
export KUBECONFIG=$(terraform output --raw path_to_kubeconfig_file)
# Gran the namespace in which Cilium was installed.
CILIUM_NAMESPACE=$(terraform output --raw cilium_namespace)
# Hubble Relay port
HUBBLE_RELAY_PORT=4245
# Cilium Connectivity tests namespace
TEST_NAMESPACE="cilium-test"
# All Cilium Connectivity tests namespaces
NAMESPACES=("${TEST_NAMESPACE}" "${TEST_NAMESPACE}-1")

# Run the connectivity tests.
kubectl -n "${CILIUM_NAMESPACE}" rollout status deployment/hubble-relay
kubectl -n "${CILIUM_NAMESPACE}" port-forward svc/hubble-relay 4245:80 &
PID=$!

# Wait while forwarded port will be available
while ! nc -vz localhost ${HUBBLE_RELAY_PORT} > /dev/null 2>&1 ; do
    echo "waiting for port-forward ..."
    sleep 1
done

cilium status --wait

# NS precreation is required because of https://www.talos.dev/v1.5/kubernetes-guides/configuration/pod-security/
for ns in "${NAMESPACES[@]}"; do
    kubectl create ns $ns
    kubectl label ns $ns pod-security.kubernetes.io/enforce=privileged
    kubectl label ns $ns pod-security.kubernetes.io/warn=privileged
done

cilium connectivity test --namespace "${CILIUM_NAMESPACE}" --test-namespace "${TEST_NAMESPACE}"

trap '{
    kill -9 "${PID}"
    for ns in "${NAMESPACES[@]}"; do
        kubectl delete ns $ns
    done
}' EXIT