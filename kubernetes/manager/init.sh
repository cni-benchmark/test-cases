#!/usr/bin/env bash
set -xeuo pipefail

kubectl apply -f 'https://github.com/cni-benchmark/test-cases/raw/refs/heads/main/kubernetes/manager/flux-system/gotk-components.yaml'
kubectl apply -k 'https://github.com/cni-benchmark/test-cases.git/kubernetes/manager/flux-system?ref=main'
kubectl apply -k 'https://github.com/cni-benchmark/test-cases.git/kubernetes/manager?ref=main'
