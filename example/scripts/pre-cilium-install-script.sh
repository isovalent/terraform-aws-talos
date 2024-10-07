#!/usr/bin/env bash

set -uo pipefail

# Wait for the Kubernetes API server to be reachable.
while ! kubectl get namespace > /dev/null 2>&1;
do
  sleep 10
done

kubectl create -n kube-system secret generic cilium-ipsec-keys \
  --from-literal=keys="3 rfc4106(gcm(aes)) $(echo $(dd if=/dev/urandom count=20 bs=1 2> /dev/null | xxd -p -c 64)) 128"

# TBD