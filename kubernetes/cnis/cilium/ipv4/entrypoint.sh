#!/usr/bin/env bash
set -euxo pipefail

arch="$(uname -m | sed -r 's/x86_/amd/g; s/aarch/arm/g')"
curl -L https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-$arch.tar.gz | \
tar -C /tmp -xpzf - cilium

xargs -0I% yq % values.yaml <<EOF | tee /tmp/values.yaml
.k8sServiceHost = env(K8S_SERVICE_HOSTNAME) |
.k8sServicePort = env(K8S_SERVICE_PORT) |
.ipam.operator.clusterPoolIPv4PodCIDRList = [env(K8S_POD_CIDR_IPV4)]
EOF
/tmp/cilium install --version "v$CNI_VERSION" -f /tmp/values.yaml || \
/tmp/cilium upgrade --version "v$CNI_VERSION" -f /tmp/values.yaml
