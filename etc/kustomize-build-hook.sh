#!/usr/bin/env bash
set -euo pipefail

export ROOT=./tests
export KUSTOMIZE=""
export LOG="$(mktemp)"
export MAX_JOBS=100  # Adjust based on system capability

main() {
  find_binary
  build_stacks
  if grep -qiF error "$LOG"; then
    cat "$LOG"
    rm -f "$LOG"
    exit 1
  fi
  rm -f "$LOG"
}

find_binary() {
  if command -v kustomize >/dev/null 2>&1; then
    KUSTOMIZE="$(command -v kustomize) build"
  elif command -v kubectl >/dev/null 2>&1; then
    KUSTOMIZE="$(command -v kubectl) kustomize"
  else
    echo "error: neither kubectl nor kustomize was found" 1>&2
    exit 1
  fi
  echo "info: using ${KUSTOMIZE}"
}

build_stacks() {
  local files
  mapfile -t files < <(find "$ROOT" -type f -name kustomization.yaml)
  
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "info: No kustomization.yaml files found."
    return
  fi

  local -a pids=()
  for file in "${files[@]}"; do
    if grep -qE 'kind:\s+Component' "$file"; then
      continue
    fi

    build "$file" &
    pids+=("$!")

    # Limit concurrent jobs
    if [[ ${#pids[@]} -ge $MAX_JOBS ]]; then
      wait "${pids[0]}"
      unset 'pids[0]'
      pids=("${pids[@]}")  # Rebuild array to remove first element
    fi
  done

  # Wait for remaining processes
  wait
}

build(){
  local file dir
  file="${1:?file is not set}"
  dir="$(dirname "$file")"
  ${KUSTOMIZE} "$dir" >/dev/null 2>>"$LOG" || true
}

main
