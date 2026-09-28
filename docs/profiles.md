# Kernel profiles

`scripts/prepare-config.sh` downloads the current Arch kernel config, merges `config/fragments/aegis-common.config`, then merges one profile fragment, then runs `make olddefconfig`.

Common options:

- `CONFIG_PREEMPT_DYNAMIC` so the boot parameter selects the preemption model
- `CONFIG_NO_HZ_IDLE` and high-resolution timers
- schedutil, performance, and powersave governors are all built in
- `CONFIG_ENERGY_MODEL`
- zstd kernel and module compression
- zswap with zstd
- debug info disabled so the package stays small

| Profile | Fragment | Default governor | Recommended cmdline |
| --- | --- | --- | --- |
| balanced | `aegis-balanced.config` | schedutil | `preempt=voluntary` |
| performance | `aegis-performance.config` | performance | `preempt=full` |
| powersave | `aegis-powersave.config` | powersave | `preempt=none` |

Powersave also selects `CONFIG_HZ_250`. The other profiles keep `CONFIG_HZ_1000`.

Do not add BORE, CachyOS, TT, BMQ, or PDS options. `scripts/check-fragments.sh` rejects them. CPU vulnerability mitigations stay at the upstream default.
