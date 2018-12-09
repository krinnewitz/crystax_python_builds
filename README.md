## CrystaX Python builds [![CircleCI](https://circleci.com/gh/TheBrokenRail/crystax_python_builds/tree/master.svg?style=svg)](https://circleci.com/gh/TheBrokenRail/crystax_python_builds/tree/master)

This repository hosts the files needed for CrystaX to build newer versions of Python that aren't yet built in.

### Supported Python Versions
- Python 2.7

- Python 3.4

- Python 3.5

- Python 3.6

- Python 3.7

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
