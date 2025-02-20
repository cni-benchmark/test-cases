#!/usr/bin/env bash
set -euxo pipefail

arch="$(uname -m | sed -r 's/x86_/amd/g; s/aarch/arm/g')"
curl -L https://github.com/cilium/cilium-cli/releases/download/v$CNI_VERSION/cilium-linux-$arch.tar.gz | \
tar -xpzf - cilium

xargs -0I% yq % values.yaml <<EOF
.k8sServiceHost = env(K8S_SERVICE_HOSTNAME) |
.k8sServicePort = env(K8S_SERVICE_PORT) |
.ipam.operator.clusterPoolIPv4PodCIDRList = [env(K8S_POD_CIDR_IPV4)]
EOF
cilium install -f values.yaml
