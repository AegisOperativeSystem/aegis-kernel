# Maintainer: Aegis OS <https://github.com/AegisOperativeSystem>
pkgbase=linux-aegis
pkgver=6.18.54
pkgrel=1
pkgdesc='Aegis OS kernel'
arch=(x86_64)
url='https://github.com/AegisOperativeSystem/aegis-kernel'
license=(GPL-2.0-only)
makedepends=(
  bc
  cpio
  gettext
  libelf
  pahole
  perl
  python
  tar
  xz
  kmod
  curl
)
options=('!strip')
_srcname="linux-${pkgver}"
_profile="${AEGIS_KERNEL_PROFILE:-balanced}"
source=(
  "https://cdn.kernel.org/pub/linux/kernel/v${pkgver%%.*}.x/${_srcname}.tar.xz"
  "https://cdn.kernel.org/pub/linux/kernel/v${pkgver%%.*}.x/${_srcname}.tar.sign"
  "linux-aegis.preset"
)
validpgpkeys=(
  'ABAF11C65A2970B130ABE3C479BE3E4300411886'
  '647F28654894E3BD457199BE38DBBDC86092693E'
)
sha256sums=('SKIP' 'SKIP' 'SKIP')

prepare() {
  cd "${_srcname}"
  echo '-aegis' > localversion.10-pkgname
  gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys \
    ABAF11C65A2970B130ABE3C479BE3E4300411886 \
    647F28654894E3BD457199BE38DBBDC86092693E
  xz -dc "../${_srcname}.tar.xz" | gpg --batch --verify "../${_srcname}.tar.sign" -
  "${startdir}/scripts/prepare-config.sh" "${_profile}" "${srcdir}/${_srcname}"
  make -s kernelrelease > version
  echo "prepared $(<version)"
}

build() {
  cd "${_srcname}"
  make all
}

_package() {
  pkgdesc="Aegis OS kernel and modules (${_profile})"
  depends=(coreutils initramfs kmod)
  optdepends=(
    'linux-firmware: device firmware'
    'wireless-regdb: wireless regulatory database'
  )
  provides=(VIRTUALBOX-GUEST-MODULES WIREGUARD-MODULE KSMBD-MODULE)
  cd "${_srcname}"
  local modulesdir="${pkgdir}/usr/lib/modules/$(<version)"
  install -Dm644 "$(make -s image_name)" "${modulesdir}/vmlinuz"
  install -Dm644 "${modulesdir}/vmlinuz" "${pkgdir}/boot/vmlinuz-${pkgbase}"
  make INSTALL_MOD_PATH="${pkgdir}/usr" INSTALL_MOD_STRIP=1 modules_install
  rm -f "${modulesdir}/"{source,build}
  install -Dm644 .config "${modulesdir}/config"
  install -Dm644 "${srcdir}/linux-aegis.preset" "${pkgdir}/etc/mkinitcpio.d/${pkgbase}.preset"
}

_package-headers() {
  pkgdesc="Headers for building modules against the Aegis OS kernel"
  depends=(pahole)
  cd "${_srcname}"
  local builddir="${pkgdir}/usr/lib/modules/$(<version)/build"
  install -Dt "${builddir}" -m644 .config Makefile Module.symvers System.map version vmlinux
  install -Dt "${builddir}/kernel" -m644 kernel/Makefile
  install -Dt "${builddir}/arch/x86" -m644 arch/x86/Makefile
  cp -a scripts "${builddir}/"
  if [[ -x tools/objtool/objtool ]]; then
    install -Dt "${builddir}/tools/objtool" tools/objtool/objtool
  fi
  cp -a include "${builddir}/"
  mkdir -p "${builddir}/arch/x86"
  cp -a arch/x86/include "${builddir}/arch/x86/"
  install -Dt "${builddir}/arch/x86/kernel" -m644 arch/x86/kernel/asm-offsets.s
  find . -name 'Kconfig*' -exec install -Dm644 {} "${builddir}/{}" \;
  ln -sr "${builddir}" "${pkgdir}/usr/src/${pkgbase}"
}

pkgname=("${pkgbase}" "${pkgbase}-headers")
for _p in "${pkgname[@]}"; do
  eval "package_${_p}() {
    $(declare -f "_package${_p#"${pkgbase}"}")
    _package${_p#"${pkgbase}"}
  }"
done
