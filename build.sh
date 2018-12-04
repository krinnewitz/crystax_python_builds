#!/bin/bash

set -e

ROOT=$(pwd)

USAGE='USAGE:\nbuild.sh <NDK Dir> <Patch Dir> <C File Suffix / Python Major.Minor> <CPython Branch>\n\nExample:\n  Python 3.7:\n    build.sh ./crystax-ndk python3.7 3.7 v3.7.1\n  Python 3.6:\n    build.sh ./crystax-ndk python3.6 3.6 v3.6.7'
SHOW_USAGE=0

NDK_PATH=$(realpath $1)
PATCH_DIR=$(realpath $2)
C_SUFFIX=$(realpath $3)
CPYTHON_BRANCH=$(realpath $4)

if [[ ! -e ${NDK_PATH}/build/tools/build-target-python.sh ]]; then
  SHOW_USAGE=1
  echo 'ERROR: Invalid NDK Dir'
fi
if [[ ! -d ${PATCH_DIR} ]]; then
  echo 'ERROR: Cannot Find Patch Dir'
  SHOW_USAGE=1
else
  if [[ ! -e ${PATCH_DIR}/Android.mk ]]; then
    echo "ERROR: Cannot Find ${PATCH_DIR}/Android.mk"
    SHOW_USAGE=1
  fi
  if [[ ! -e ${PATCH_DIR}/android.mk.${C_SUFFIX} ]]; then
    echo "ERROR: Cannot Find ${PATCH_DIR}/android.mk.${C_SUFFIX}"
    SHOW_USAGE=1
  fi
  if [[ ! -e ${PATCH_DIR}/config.c.${C_SUFFIX} ]]; then
    echo "ERROR: Cannot Find ${PATCH_DIR}/config.c.${C_SUFFIX}"
    SHOW_USAGE=1
  fi
  if [[ ! -e ${PATCH_DIR}/interpreter.c.${C_SUFFIX} ]]; then
    echo "ERROR: Cannot Find ${PATCH_DIR}/interpreter.c.${C_SUFFIX}"
    SHOW_USAGE=1
  fi
fi

if [[ -d cpython ]]; then
  rm -rf cpython
fi

if [[ ${SHOW_USAGE} == 1 ]]; then
  echo -e "${USAGE}"
  exit 1
fi

cp ${PATCH_DIR}/*.${C_SUFFIX} ${NDK_PATH}/build/tools/build-target-python
mkdir -p ${NDK_PATH}/sources/python/${C_SUFFIX}
cp ${PATCH_DIR}/Android.mk ${NDK_PATH}/sources/python/${C_SUFFIX}/Android.mk

git clone --depth=1 https://github.com/python/cpython.git -b ${CPYTHON_BRANCH}

if [[ ! -d cpython/Modules/_ctypes/libffi ]]; then
  git clone --depth=1 https://github.com/libffi/libffi.git -b v3.1 cpython/Modules/_ctypes/libffi
  cd cpython/Modules/_ctypes/libffi

  patch -p1 < ${PATCH_DIR}/libffi/libffi.patch
  cp ${PATCH_DIR}/libffi/fficonfig.py.in ./
  ./autogen.sh
  cd ${ROOT}
fi

cd cpython
if [[ -e ${PATCH_DIR}/patch_python.patch ]]; then
  patch -p1 < ${PATCH_DIR}/patch_python.patch
fi
ln -s $(pwd)/Lib/site-packages/README.txt $(pwd)/Lib/site-packages/README
cd ${ROOT}

if [[ -e ${PATCH_DIR}/python-script.patch ]]; then
  cd ${NDK_PATH}
  patch -p1 < ${PATCH_DIR}/python-script.patch
  cd ${ROOT}
fi

${NDK_PATH}/build/tools/build-target-python.sh --ndk_dir=${NDK_PATH} --abis=armeabi,armeabi-v7a,arm64-v8a,x86,x86_64,mips,mips64 --verbose $(pwd)/cpython | awk '/^\[|^##/'

rm -rf cpython

if [[ -e ${PATCH_DIR}/python-script.patch ]]; then
  cd ${NDK_PATH}
  patch -p1 -R < ${ROOT}/${PATCH_DIR}/python-script.patch
  cd ${ROOT}
fi
