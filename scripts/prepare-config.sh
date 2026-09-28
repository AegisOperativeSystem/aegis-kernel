#!/usr/bin/env bash
set -euo pipefail

profile="${1:-balanced}"
kernel_tree="${2:?kernel source tree}"
base_config="${3:-}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${profile}" in
  balanced|performance|powersave) ;;
  *)
    echo "profile must be balanced, performance, or powersave" >&2
    exit 1
    ;;
esac

base="$(mktemp)"
trap 'rm -f "${base}"' EXIT
if [[ -n "${base_config}" ]]; then
  cp "${base_config}" "${base}"
else
  curl -fsSL -o "${base}" \
    https://gitlab.archlinux.org/archlinux/packaging/packages/linux/-/raw/main/config
fi

cp "${base}" "${kernel_tree}/.config"
(
  cd "${kernel_tree}"
  scripts/kconfig/merge_config.sh -m .config \
    "${root}/config/fragments/aegis-common.config" \
    "${root}/config/fragments/aegis-${profile}.config"
  make olddefconfig
)
echo "prepared ${profile} config in ${kernel_tree}/.config"
