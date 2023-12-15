#!/bin/bash
set -e

#export PATH="${WEBR_ROOT}/wasm/bin:${PATH}"
SOURCEPKG="${1:-$SOURCEPKG}"
GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/stdout}

# Restore package cache dir
export R_LIBS_USER="${PWD}/pkglib"
R -e ".libPaths(); installed.packages()[,1:3]"

# Some debugging output
echo "::group::List available wasm libraries"
PKG_CONFIG_LIBDIR="${WEBR_ROOT}/wasm/lib/pkgconfig" pkg-config --list-all
echo "::endgroup::"
echo "::group::Test that pkg-config works"
PKG_CONFIG_LIBDIR="${WEBR_ROOT}/wasm/lib/pkgconfig" pkg-config --libs --cflags gdal
echo "::endgroup::"

# For the GitHub Action
if [ "$SOURCEPKG" ]; then
	R -e "rwasm::build('./${SOURCEPKG}')"
	BINARYPKG=${SOURCEPKG/.tar.gz/.tgz}
	echo "binarypkg=$BINARYPKG" >> $GITHUB_OUTPUT
fi
