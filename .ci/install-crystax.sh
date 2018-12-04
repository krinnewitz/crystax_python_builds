#!/bin/bash
set -e

if [[ -d crystax-ndk ]]; then
    rm -rf crystax-ndk
fi
curl -L -o crystax-ndk.tar.xz https://www.crystax.net/download/crystax-ndk-10.3.2-linux-x86_64.tar.xz
mkdir crystax-ndk
tar xfJ crystax-ndk.tar.xz --strip-components=1 -C crystax-ndk
rm -rf crystax-ndk.tar.xz
