
CrystaX Python builds
=====================

This repository hosts the files needed for CrystaX to build versions
of Python that aren't yet built in.

For now, the extra files support only Python 3.6.

The releases for this repository include prebuilt Python versions for
some target architectures, which can simply be extracted and copied
directly into place.

Instructions
============

1) Download the ``CrystaX NDK <https://www.crystax.net/en/android/ndk>`` to some path ``$NDK_DIR``.

2) Copy android.mk.3.6, config.c.3.6 and interpreter.c.3.6 to:

   ``$NDK_DIR/build/tools/build-target-python``

3) Create the Python 3.6 dir:

  ``mkdir $NDK_DIR/sources/python/3.6``

4) Copy the Android.mk into place:

  ``cp Android.mk $NDK_DIR/sources/python/3.6/Android.mk``

5) Download the Python 3.6 source to some path ``$PYTHON_DIR``.

6) Patch the Python 3.6 source with:

  ``patch -p1 < patch_python3.6.patch``

7) Fix missing/renamed README with:

  ``ln -s $PYTHON_DIR/Lib/site-packages/README.txt $PYTHON_DIR/Lib/site-packages/README``

The changes made are very minor, but hacky; an improvement for the future will be to fix the CrystaX build, or Python itself, to not need them.

8) Add `-DXML_POOR_ENTROPY` to the `pyexpat` `CFLAGS` in ``$NDK_DIR/build/tools/build-target-python.sh``.

9) Run the ``build-target-python.sh`` script:

   ``$NDK_DIR/build/tools/build-target-python.sh --ndk_dir=$NDK_DIR --abis=armeabi,armeabi-v7a,arm64-v8a,x86,x86_64,mips,mips64 --verbose $PYTHON_DIR``

This should build Python for the target architectures and copy it into place so that it can be used like any other.
