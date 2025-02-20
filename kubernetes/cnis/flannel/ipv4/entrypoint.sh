#!/usr/bin/env bash
set -euxo pipefail

kubectl apply -f "https://github.com/flannel-io/flannel/releases/download/v$CNI_VERSION/kube-flannel.yml"
