#!/usr/bin/env bash
set -euxo pipefail

kubectl apply -f "https://github.com/flannel-io/flannel/releases/download/v$CNI_VERSION/kube-flannel.yml"
kubectl -n kube-flannel patch daemonset kube-flannel-ds \
  --type=json --patch-file=/dev/stdin <<EOF
- op: add
  path: /spec/template/spec/containers/0/env/-
  value:
    name: KUBERNETES_SERVICE_HOST
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
- op: add
  path: /spec/template/spec/containers/0/env/-
  value:
    name: KUBERNETES_SERVICE_PORT
    value: "6443"
EOF
