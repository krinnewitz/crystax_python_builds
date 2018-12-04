#!/bin/bash

set -e

ROOT=$(pwd)

USAGE='USAGE:\nbuild.sh <NDK Dir> <Patch Dir> <C File Suffix / Python Major.Minor> <CPython Branch>\n\nExample:\n  Python 3.7:\n    build.sh ./crystax-ndk python3.7 3.7 v3.7.1\n  Python 3.6:\n    build.sh ./crystax-ndk python3.6 3.6 v3.6.7'
SHOW_USAGE=0
if [[ ! -e $1/build/tools/build-target-python.sh ]]; then
  SHOW_USAGE=1
  echo 'ERROR: Invalid NDK Dir'
fi
if [[ ! -d $2 ]]; then
  echo 'ERROR: Cannot Find Patch Dir'
  SHOW_USAGE=1
else
  if [[ ! -e $2/Android.mk ]]; then
    echo "ERROR: Cannot Find $2/Android.mk"
    SHOW_USAGE=1
  fi
  if [[ ! -e $2/android.mk.$3 ]]; then
    echo "ERROR: Cannot Find $2/android.mk.$3"
    SHOW_USAGE=1
  fi
  if [[ ! -e $2/config.c.$3 ]]; then
    echo "ERROR: Cannot Find $2/config.c.$3"
    SHOW_USAGE=1
  fi
  if [[ ! -e $2/interpreter.c.$3 ]]; then
    echo "ERROR: Cannot Find $2/interpreter.c.$3"
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

cp $2/*.$3 $1/build/tools/build-target-python
mkdir -p $1/sources/python/$3
cp $2/Android.mk $1/sources/python/$3/Android.mk

git clone --depth=1 https://github.com/python/cpython.git -b $3

if [[ ! -d cpython/Modules/_ctypes/libffi ]]; then
  git clone --depth=1 https://github.com/libffi/libffi.git -b v3.1 cpython/Modules/_ctypes/libffi
  cd cpython/Modules/_ctypes/libffi

  patch -p1 < ${ROOT}/$2/libffi/libffi.patch
  cp ${ROOT}/$2/libffi/fficonfig.py.in ./
  ./autogen.sh
  cd ${ROOT}
fi

cd cpython
if [[ -e ../$2/patch_python.patch ]]; then
  patch -p1 < ../$2/patch_python.patch
fi
ln -s $(pwd)/Lib/site-packages/README.txt $(pwd)/Lib/site-packages/README
cd ${ROOT}

if [[ -e $2/python-script.patch ]]; then
  cd $1
  patch -p1 < ${ROOT}/$2/python-script.patch
  cd ${ROOT}
fi

$1/build/tools/build-target-python.sh --ndk_dir=$(pwd)/$1 --abis=armeabi,armeabi-v7a,arm64-v8a,x86,x86_64,mips,mips64 --verbose $(pwd)/cpython | awk '^[ || ^##'

rm -rf cpython

if [[ -e $2/python-script.patch ]]; then
  cd $1
  patch -p1 -R < ${ROOT}/$2/python-script.patch
  cd ${ROOT}
fi
