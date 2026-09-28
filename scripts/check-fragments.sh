#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
frag="${root}/config/fragments"
forbidden='BORE|CACHY|TT_SCHED|UKSM|BMQ|PDS_SCHED'

for name in common balanced performance powersave; do
  file="${frag}/aegis-${name}.config"
  [[ -f "${file}" ]] || {
    echo "missing ${file}" >&2
    exit 1
  }
  if grep -E "${forbidden}" "${file}"; then
    echo "out-of-tree scheduler option in ${file}" >&2
    exit 1
  fi
done

grep -q 'CONFIG_PREEMPT_DYNAMIC=y' "${frag}/aegis-common.config"
grep -q 'CONFIG_ENERGY_MODEL=y' "${frag}/aegis-common.config"
grep -q 'CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL=y' "${frag}/aegis-balanced.config"
grep -q 'CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y' "${frag}/aegis-performance.config"
grep -q 'CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE=y' "${frag}/aegis-powersave.config"
grep -q 'CONFIG_HZ_250=y' "${frag}/aegis-powersave.config"
echo "kernel fragments ok"
