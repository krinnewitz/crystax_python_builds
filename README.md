## CrystaX Python builds [![Build Status](https://travis-ci.com/TheBrokenRail/crystax_python_builds.svg?branch=master)](https://travis-ci.com/TheBrokenRail/crystax_python_builds)

This repository hosts the files needed for CrystaX to build versions
of Python that aren't yet built in.

For now, the extra files support only Python 3.6 and 3.7.

The releases for this repository include prebuilt Python versions for
some target architectures, which can simply be extracted and copied
directly into place.

## Instructions

1) Run ```./build.sh```

```
USAGE:
  build.sh <NDK Dir> <Patch Dir> <C File Suffix / Python Major.Minor> <CPython Branch> [Custom CPython Git]
  build.sh <NDK Dir> <Patch Dir>

Example:
  Python 3.7:
    build.sh ./crystax-ndk python3.7
  Python 3.6:
    build.sh ./crystax-ndk python3.6
  Python 3.7 Dev:
    build.sh ./crystax-ndk python3.7 3.7 3.7
  Python 3.6 Dev:
    build.sh ./crystax-ndk python3.6 3.6 3.6
```

This should build Python for the target architectures and copy it into place so that it can be used like any other.
