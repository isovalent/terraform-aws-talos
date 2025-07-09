#!/usr/bin/env bash

set -euxo pipefail

# Grab the path to the kubeconfig file.
export KUBECONFIG=$(terraform output --raw path_to_kubeconfig_file)
# Gran the namespace in which Cilium was installed.
CILIUM_NAMESPACE=$(terraform output --raw cilium_namespace)
# Cilium Connectivity tests namespace
TEST_NAMESPACE="cilium-test"
# All Cilium Connectivity tests namespaces
NAMESPACES=("${TEST_NAMESPACE}" "${TEST_NAMESPACE}-1")

cilium status --wait

# NS precreation is required because of https://www.talos.dev/v1.5/kubernetes-guides/configuration/pod-security/
for ns in "${NAMESPACES[@]}"; do
    kubectl create ns $ns
    kubectl label ns $ns pod-security.kubernetes.io/enforce=privileged
    kubectl label ns $ns pod-security.kubernetes.io/warn=privileged
done

cilium connectivity test --namespace "${CILIUM_NAMESPACE}" --test-namespace "${TEST_NAMESPACE}" --hubble=false --flow-validation=disabled --test "!no-policies,!allow-all-except-world"

trap '{
    for ns in "${NAMESPACES[@]}"; do
        kubectl delete ns $ns
    done
}' EXIT