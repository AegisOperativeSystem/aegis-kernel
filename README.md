# aegis-kernel

`linux-aegis` is the Aegis OS kernel. It tracks Linux 6.18 longterm, starting at 6.18.54, and applies config fragments on top of the Arch `linux` config. There are no out-of-tree scheduler patches.

Profiles are `balanced` (default), `performance`, and `powersave`. See [docs/profiles.md](docs/profiles.md).

```bash
./scripts/check-fragments.sh
AEGIS_KERNEL_PROFILE=balanced ./scripts/build-package.sh
```

A `vX.Y.Z` tag compiles the kernel, signs it when `AEGIS_GPG_PRIVATE_KEY` is set, and uploads the package to the GitHub release. Pull requests only validate the fragments.

The source tarball is verified with the kernel.org signature for Linus Torvalds or Greg Kroah-Hartman.
