#!/usr/bin/env bash

# Dependencies
deps() {
    echo "Cloning dependencies"
    if [ ! -d "clang" ]; then
        wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-14.0.0_r2/clang-r487747c.tar.gz -O "aosp-clang.tar.gz"
        mkdir clang && tar -xf aosp-clang.tar.gz -C clang && rm -rf aosp-clang.tar.gz
        KBUILD_COMPILER_STRING="Clang 17.0.2 r487747c"
        PATH="${PWD}/clang/bin:${PATH}"
    fi
    sudo apt install -y ccache
    echo "Done"
}

IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%Y%m%d-%H%M")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
CACHE=1
export CACHE
export KBUILD_COMPILER_STRING
ARCH=arm64
export ARCH
KBUILD_BUILD_HOST="neOliT"
export KBUILD_BUILD_HOST
KBUILD_BUILD_USER="sarthakroy2002"
export KBUILD_BUILD_USER
DEVICE="Realme C3/Narzo 10A (Realme Monet)"
export DEVICE
CODENAME="RMX2020"
export CODENAME
DEFCONFIG="RMX2020_defconfig"
export DEFCONFIG
COMMIT_HASH=$(git rev-parse --short HEAD)
export COMMIT_HASH
PROCS=$(nproc --all)
export PROCS
STATUS=BETA
export STATUS
source "${HOME}"/.bashrc && source "${HOME}"/.profile
if [ $CACHE = 1 ]; then
    ccache -M 100G
    export USE_CCACHE=1
fi
LC_ALL=C
export LC_ALL

# Compile
compile() {

    if [ -d "out" ]; then
        rm -rf out && mkdir -p out
    fi

    make O=out ARCH="${ARCH}" "${DEFCONFIG}"
    make -j"${PROCS}" O=out \
        ARCH=$ARCH \
        CC="clang" \
        LLVM=1 \
        CONFIG_NO_ERROR_ON_MISMATCH=y

    if ! [ -a "$IMAGE" ]; then
        finderr
        exit 1
    fi

    git clone --depth=1 https://github.com/sarthakroy2002/AnyKernel3.git AnyKernel
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}

deps
compile
