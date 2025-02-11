#!/usr/bin/env bash
set -xeuo pipefail

kubectl apply -f 'https://github.com/cni-benchmark/test-cases/raw/refs/heads/main/manager/kubernetes/flux-system/gotk-components.yaml'
kubectl apply -k 'https://github.com/cni-benchmark/test-cases.git/manager/kubernetes/flux-system?ref=main'
kubectl apply -k 'https://github.com/cni-benchmark/test-cases.git/manager/kubernetes?ref=main'
