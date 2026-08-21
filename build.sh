#!/bin/bash
# ============================================================================
#  Build Script Kernel  —  Galaxy S20 FE 4G Exynos (SM-G780F / r8slte)
#  Toolchain: Clang + GCC 4.9 localizados na pasta toolchain/ interna.
# ============================================================================
set -e

BASE="exynos9830-r8slte_defconfig"
OUT="out_r8slte"

ROOT="$(cd "$(dirname "$0")" && pwd)"
CLANG_DIR="${CLANG_DIR:-$ROOT/toolchain/prebuilts_clang_host_linux-x86_clang-r349610-jopp}"
GCC_DIR="${GCC_DIR:-$ROOT/toolchain/gcc-cfp/gcc-cfp-jopp-only/aarch64-linux-android-4.9}"

[ -x "$CLANG_DIR/bin/clang" ] || { echo "ERROR: clang não encontrado em $CLANG_DIR"; exit 1; }

export PATH="$CLANG_DIR/bin:$GCC_DIR/bin:$PATH"
export ARCH=arm64 SUBARCH=arm64 LC_ALL=C

# Macros Kconfig exigidas pela Samsung
export PLATFORM_VERSION=13 ANDROID_MAJOR_VERSION=t SEC_BUILD_CONF_VENDOR_BUILD_OS=13

HCF='-fcommon -Wno-error -Wno-deprecated-declarations -Wno-implicit-function-declaration'
KCF='-Wno-unknown-warning-option -fno-builtin-stpcpy -fno-builtin-strlcpy -Wno-error -Wno-strict-prototypes -Wno-old-style-definition -Wno-implicit-function-declaration -Wno-int-conversion -Wno-incompatible-pointer-types -Wno-unused-function -Wno-implicit-int -Wno-format'

COMMON="ARCH=arm64 SUBARCH=arm64 O=$OUT CC=clang HOSTCC=gcc HOSTLD=ld CROSS_COMPILE=aarch64-linux-android- CLANG_TRIPLE=aarch64-linux-gnu-"

cd "$ROOT"
echo "================================================="
echo " Building Kernel: S20 FE (r8slte)"
echo " Base Config: $BASE"
echo " Clang: $("$CLANG_DIR/bin/clang" --version | head -1)"
echo "================================================="

# 1. Gerar defconfig inicial
make $COMMON "KBUILD_HOSTCFLAGS=$HCF" "HOSTCFLAGS=$HCF" -j"$(nproc)" "$BASE"

# 2. Mesclar ksu.config (se existir no repositório)
if [ -f "arch/arm64/configs/ksu.config" ]; then
    echo ">> Aplicando fragmento ksu.config..."
    cat arch/arm64/configs/ksu.config >> "$OUT/.config"
    make $COMMON "KBUILD_HOSTCFLAGS=$HCF" "HOSTCFLAGS=$HCF" -j"$(nproc)" olddefconfig
fi

# 3. Compilar Imagem
echo ">> Compilando com $(nproc) núcleos..."
make $COMMON "KBUILD_HOSTCFLAGS=$HCF" "HOSTCFLAGS=$HCF" "KCFLAGS=$KCF" -j"$(nproc)" Image

IMG="$OUT/arch/arm64/boot/Image"
if [ -f "$IMG" ]; then
  echo "================================================="
  echo " SUCESSO: $IMG"
  echo " Tamanho: $(stat -c%s "$IMG") bytes"
  echo "================================================="
else
  echo "================================================="
  echo " FALHA NA COMPILAÇÃO"
  echo "================================================="
  exit 1
fi
