#!/bin/bash
set -e

# start fake X server (for e.g. gWidgets2tcltk)
nohup Xvfb :6 -screen 0 1280x1024x24 > ~/X.log 2>&1 &
export DISPLAY=:6
echo "Running fake X server on $DISPLAY"

#export PATH="${WEBR_ROOT}/wasm/bin:${PATH}"
SOURCEPKG="${1:-$SOURCEPKG}"
GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/stdout}

# Make sure we have laste rust
if [ "$NEED_CARGO" ]; then
  echo "::group::Update Rust"
  rustup update stable nightly || true
  echo "::endgroup::"
fi

# Use package cache dir
export R_LIBS_USER="${PWD}/pkglib"

# Some debugging output
echo "::group::List installed R packages"
R -e ".libPaths(); installed.packages()[,1:3]"
echo "::endgroup::"

echo "::group::List available wasm libraries"
PKG_CONFIG_LIBDIR="${WEBR_ROOT}/wasm/lib/pkgconfig" pkg-config --list-all
echo "::endgroup::"

echo "::group::Test that pkg-config works"
PKG_CONFIG_LIBDIR="${WEBR_ROOT}/wasm/lib/pkgconfig" pkg-config --libs --cflags gdal
echo "::endgroup::"

echo "::group::Get native dependencies"
# R -e "install.packages(sub('_.*', '', '${SOURCEPKG}'), depends=TRUE)" || true

# (Re)build linux native binary (also ensures dev-deps are present)
# This is expensive, maybe we should copy the binary from the previous job
R -e "pak::pak('./${SOURCEPKG}')"
echo "::endgroup::"

# Compile WASM binary
R -e "rwasm::build('./${SOURCEPKG}')"
BINARYPKG=${SOURCEPKG/.tar.gz/.tgz}
echo "binarypkg=$BINARYPKG" >> $GITHUB_OUTPUT
