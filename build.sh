#!/bin/bash

set -e

ROOT=$(pwd)

USAGE='\e[1mUSAGE:\e[0m\n  build.sh <NDK Dir> <Patch Dir> <C File Suffix / Python Major.Minor> <CPython Branch> [Custom CPython Git]\n  build.sh <NDK Dir> <Patch Dir>\n\nExample:\n  Python 3.7:\n    build.sh ./crystax-ndk python3.7\n  Python 3.6:\n    build.sh ./crystax-ndk python3.6\n  Python 3.7 Dev:\n    build.sh ./crystax-ndk python3.7 3.7 3.7\n  Python 3.6 Dev:\n    build.sh ./crystax-ndk python3.6 3.6 3.6'
SHOW_USAGE=0

realpath() {
  if [[ $1 == /* ]]; then
    echo $1
  else
    echo $(pwd)/$1
  fi
}

usage() {
  echo -e "${USAGE}"
  exit 1
}

if [[ -z $1 ]]; then
  usage
fi

NDK_PATH=$(realpath $1)
PATCH_DIR=$(realpath $2)

INFO="\e[1mINFO:\e[0m"
ERROR="\e[1m\e[31mERROR:\e[0m"

CPYTHON_GIT='https://github.com/python/cpython.git'
if [[ -z "$3" ]]; then
  if [[ -e ${PATCH_DIR}/defaults.sh ]]; then
    echo -e "${INFO} Using Defaults"
    source ${PATCH_DIR}/defaults.sh
  else
    echo -e "${ERROR} Cannot Find ${PATCH_DIR}/defaults.sh"
	usage
  fi
else
  C_SUFFIX=$3
  CPYTHON_BRANCH=$4
  if [[ ! -z $5 ]]; then
    CPYTHON_GIT=$5
  fi
fi
echo -e "${INFO} Using CPython Git: ${CPYTHON_GIT}"
echo -e "${INFO} Using CPython Branch: ${CPYTHON_BRANCH}"

if [[ ! -e ${NDK_PATH}/build/tools/build-target-python.sh ]]; then
  SHOW_USAGE=1
  echo -e "${ERROR} Invalid NDK Dir"
else
  echo -e "${INFO} Using NDK: ${NDK_PATH}"
fi
if [[ ! -d ${PATCH_DIR} ]]; then
  echo -e "${ERROR} Cannot Find Patch Dir"
  SHOW_USAGE=1
else
  echo -e "${INFO} Using Patch Dir: ${PATCH_DIR}"
  if [[ ! -e ${PATCH_DIR}/Android.mk ]]; then
    echo -e "${ERROR} Cannot Find ${PATCH_DIR}/Android.mk"
    SHOW_USAGE=1
  fi
  if [[ ! -e ${PATCH_DIR}/android.mk.${C_SUFFIX} ]]; then
    echo -e "${ERROR} Cannot Find ${PATCH_DIR}/android.mk.${C_SUFFIX}"
    SHOW_USAGE=1
  fi
  if [[ ! -e ${PATCH_DIR}/config.c.${C_SUFFIX} ]]; then
    echo -e "${ERROR} Cannot Find ${PATCH_DIR}/config.c.${C_SUFFIX}"
    SHOW_USAGE=1
  fi
  if [[ ! -e ${PATCH_DIR}/interpreter.c.${C_SUFFIX} ]]; then
    echo -e "${ERROR} Cannot Find ${PATCH_DIR}/interpreter.c.${C_SUFFIX}"
    SHOW_USAGE=1
  fi
fi

if [[ -d cpython ]]; then
  rm -rf cpython
fi

if [[ ${SHOW_USAGE} == 1 ]]; then
  usage
fi

cp ${PATCH_DIR}/*.${C_SUFFIX} ${NDK_PATH}/build/tools/build-target-python
if [[ -d ${NDK_PATH}/sources/python/${C_SUFFIX} ]]; then
  rm -rf ${NDK_PATH}/sources/python/${C_SUFFIX}
fi
mkdir -p ${NDK_PATH}/sources/python/${C_SUFFIX}
cp ${PATCH_DIR}/Android.mk ${NDK_PATH}/sources/python/${C_SUFFIX}/Android.mk

git clone --depth=1 ${CPYTHON_GIT} -b ${CPYTHON_BRANCH} cpython

if [[ ! -d cpython/Modules/_ctypes/libffi ]]; then
  git clone --depth=1 https://github.com/libffi/libffi.git -b v3.1 cpython/Modules/_ctypes/libffi
  cd cpython/Modules/_ctypes/libffi

  patch -p1 < ${PATCH_DIR}/libffi/libffi.patch
  cp ${PATCH_DIR}/libffi/fficonfig.py.in ./
  ./autogen.sh
  cd ${ROOT}
fi

cd cpython
if [[ -e ${PATCH_DIR}/python.patch ]]; then
  patch -p1 < ${PATCH_DIR}/python.patch
fi
if [[ ! -e Lib/site-packages/README ]]; then
  ln -s $(pwd)/Lib/site-packages/README.txt $(pwd)/Lib/site-packages/README
fi
cd ${ROOT}

if [[ -e ${PATCH_DIR}/python-script.patch ]]; then
  cd ${NDK_PATH}
  patch -p1 < ${PATCH_DIR}/python-script.patch
  cd ${ROOT}
fi

${NDK_PATH}/build/tools/build-target-python.sh --ndk_dir=${NDK_PATH} --abis=armeabi,armeabi-v7a,armeabi-v7a-hard,arm64-v8a,x86,x86_64,mips,mips64 --verbose $(pwd)/cpython

rm -rf cpython

if [[ -e ${PATCH_DIR}/python-script.patch ]]; then
  cd ${NDK_PATH}
  patch -p1 -R < ${PATCH_DIR}/python-script.patch
  cd ${ROOT}
fi
