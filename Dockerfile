FROM ubuntu:bionic

ENV BINUTILS_VERSION "binutils-2.30"

# Need curl and gnupg to grab llvm. Also grab build-essential
# for binutil's build dependencies (make, etc)
RUN apt-get update && apt-get install -y curl gnupg build-essential

# Install llvm for libfuzzer.
RUN echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-8 main" \
    >> /etc/apt/sources.list
RUN echo "deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-8 main" \
    >> /etc/apt/sources.list
RUN curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add
RUN apt-get update && apt-get install -y clang-8


# Grab the target version's tarball and extract it.
RUN curl -O https://ftp.gnu.org/gnu/binutils/$BINUTILS_VERSION.tar.gz \
    && tar -xzf $BINUTILS_VERSION.tar.gz

# Work out of the extracted source directory.
WORKDIR $BINUTILS_VERSION

ENV CC clang-8
RUN ./configure
RUN make -j$(nproc) CFLAGS="-fsanitize=fuzzer-no-link"

# Change into the binutils dir and create our fuzzers.
WORKDIR binutils

ADD nm-fuzzer.patch .
RUN patch nm.c -i nm-fuzzer.patch
RUN make nm-new CFLAGS="-fsanitize=fuzzer"

ADD readelf-fuzzer.patch .
RUN patch readelf.c -i readelf-fuzzer.patch
RUN make readelf CFLAGS="-fsanitize=fuzzer"
