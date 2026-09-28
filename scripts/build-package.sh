#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${root}"

if [[ "$(id -u)" -eq 0 ]]; then
  if ! id builder >/dev/null 2>&1; then
    useradd -m builder
  fi
  printf 'builder ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/builder
  chmod 440 /etc/sudoers.d/builder
  chown -R builder:builder "${root}"
  key_file=""
  pass_file=""
  if [[ -n "${AEGIS_GPG_PRIVATE_KEY:-}" ]]; then
    key_file="/home/builder/.aegis-signing-key"
    printf '%s' "${AEGIS_GPG_PRIVATE_KEY}" > "${key_file}"
    chown builder:builder "${key_file}"
    chmod 600 "${key_file}"
  fi
  if [[ -n "${AEGIS_GPG_PASSPHRASE:-}" ]]; then
    pass_file="/home/builder/.aegis-signing-pass"
    printf '%s' "${AEGIS_GPG_PASSPHRASE}" > "${pass_file}"
    chown builder:builder "${pass_file}"
    chmod 600 "${pass_file}"
  fi
  exec su builder -c "AEGIS_KERNEL_PROFILE='${AEGIS_KERNEL_PROFILE:-balanced}' AEGIS_GPG_KEY_FILE='${key_file}' AEGIS_GPG_PASS_FILE='${pass_file}' '${root}/scripts/build-package.sh'"
fi

sign=()
if [[ -n "${AEGIS_GPG_KEY_FILE:-}" && -f "${AEGIS_GPG_KEY_FILE}" ]]; then
  mkdir -p "${HOME}/.gnupg"
  chmod 700 "${HOME}/.gnupg"
  gpg --batch --import "${AEGIS_GPG_KEY_FILE}"
  rm -f "${AEGIS_GPG_KEY_FILE}"
  if [[ -n "${AEGIS_GPG_PASS_FILE:-}" && -f "${AEGIS_GPG_PASS_FILE}" ]]; then
    cat > "${HOME}/pinentry-aegis" <<EOF
#!/bin/sh
phrase="\$(cat '${AEGIS_GPG_PASS_FILE}')"
printf 'OK\n'
while IFS= read -r line; do
  case "\${line}" in
    GETPIN)
      printf 'D %s\nOK\n' "\${phrase}"
      ;;
    BYE)
      printf 'OK\n'
      exit 0
      ;;
    *)
      printf 'OK\n'
      ;;
  esac
done
EOF
    chmod 700 "${HOME}/pinentry-aegis"
    printf 'pinentry-program %s/pinentry-aegis\nallow-loopback-pinentry\n' "${HOME}" > "${HOME}/.gnupg/gpg-agent.conf"
    gpg-connect-agent reloadagent /bye || true
  fi
  sign=(--sign)
fi

export AEGIS_KERNEL_PROFILE="${AEGIS_KERNEL_PROFILE:-balanced}"
if [[ ${#sign[@]} -gt 0 ]]; then
  makepkg -f --noconfirm --skipchecksums "${sign[@]}"
else
  makepkg -f --noconfirm --skipchecksums
fi
if [[ -n "${AEGIS_GPG_PASS_FILE:-}" ]]; then
  rm -f "${AEGIS_GPG_PASS_FILE}"
fi
mkdir -p "${root}/out"
cp -a "${root}"/*.pkg.tar.zst "${root}/out/"
if compgen -G "${root}/*.pkg.tar.zst.sig" > /dev/null; then
  cp -a "${root}"/*.pkg.tar.zst.sig "${root}/out/"
fi
