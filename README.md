# binutils-libfuzzer

This project contains [libFuzzer harnesses](https://llvm.org/docs/LibFuzzer.html#fuzz-target)
for binutils-2.30. The goal is to test similar functionality as an
out-of-process fuzzer like AFL.

_It's probably possible to forward port these changes to newer
versions of binutils somewhat easily_

## Building

A [Dockerfile](./Dockerfile) is provided for convenience,
you can build it using `docker build .` to pull down binutils
and create a container with the fuzzing binaries.

1. Make binutils using `CFLAGS="-fsanitize=fuzzer-no-link"`

2. Apply the patches into the source files under `binutils`
   for the tool you want.
   
3. Compile the tool with `CFLAGS="-fsanitize=fuzzer"`.
   For example: `make nm-new CFLAGS="-fsanitize=fuzzer"`

## Current Fuzzers

* [`nm -C`](./nm-fuzzer.patch)

* [`readelf -a`](./readelf-fuzzer.patch)
