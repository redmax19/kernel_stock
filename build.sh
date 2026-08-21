#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
CLANG_DIR="$ROOT/toolchain/prebuilts_clang_host_linux-x86_clang-r349610-jopp"
GCC_DIR="$ROOT/toolchain/gcc-cfp/gcc-cfp-jopp-only/aarch64-linux-android-4.9"

[ -x "$CLANG_DIR/bin/clang" ] || { echo "ERRO: Clang não encontrado em $CLANG_DIR"; exit 1; }

export PATH="$CLANG_DIR/bin:$GCC_DIR/bin:$PATH"
export ARCH=arm64
export SUBARCH=arm64
export LC_ALL=C

# Variáveis do ambiente Samsung / Android
export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t
export SEC_BUILD_CONF_VENDOR_BUILD_OS=13

BASE="exynos9830-r8slte_defconfig"
OUT="out_r8slte"

HCF="-fcommon -Wno-error -Wno-deprecated-declarations -Wno-implicit-function-declaration"
KCF="-Wno-unknown-warning-option -fno-builtin-stpcpy -fno-builtin-strlcpy -Wno-error -Wno-strict-prototypes -Wno-old-style-definition -Wno-implicit-function-declaration -Wno-int-conversion -Wno-incompatible-pointer-types -Wno-unused-function -Wno-implicit-int -Wno-format"

COMMON="ARCH=arm64 O=$OUT CC=clang CROSS_COMPILE=aarch64-linux-android- CLANG_TRIPLE=aarch64-linux-gnu-"

cd "$ROOT"

echo "================================================="
echo " Building Kernel Clean (Stock): S20 FE (r8slte)"
echo " Base Config: $BASE"
echo "================================================="

# 1. Limpeza opcional (descomente se precisar recriar a pasta out do zero)
# rm -rf "$OUT"

# 2. Gerar .config
make $COMMON "KBUILD_HOSTCFLAGS=$HCF" "HOSTCFLAGS=$HCF" -j"$(nproc)" "$BASE"

# 3. Compilar imagem
echo ">> Compilando com $(nproc) núcleos..."
make $COMMON "KBUILD_HOSTCFLAGS=$HCF" "HOSTCFLAGS=$HCF" "KCFLAGS=$KCF" -j"$(nproc)" Image.gz-dtb

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
