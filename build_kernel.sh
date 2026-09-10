#!/bin/bash

export HOSTCFLAGS="-fcommon -Wno-error -Wno-deprecated-declarations -Wno-implicit-function-declaration"
export HOSTCXXFLAGS="-fcommon"
export KCFLAGS="-Wno-unknown-warning-option -fno-builtin-stpcpy -fno-builtin-strlcpy -Wno-error -Wno-strict-prototypes -Wno-old-style-definition -Wno-implicit-function-declaration -Wno-int-conversion -Wno-incompatible-pointer-types -Wno-unused-function -Wno-implicit-int -Wno-format -Wno-unused-but-set-variable"

export CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
export CC=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export SEC_BUILD_CONF_VENDOR_BUILD_OS=13
export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=T
export ARCH=arm64

export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y exynos9830-r8slte_defconfig
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j4
