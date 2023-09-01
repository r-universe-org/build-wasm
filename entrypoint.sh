#!/bin/bash
set -e
source ${NVM_DIR}/nvm.sh
export EM_NODE_JS=${NVM_BIN}/node
export R_HOST="${WEBR_ROOT}/host/R-$(cat ${WEBR_ROOT}/R/R-VERSION)"
export R_VERSION_SHORT=$(grep -Eo '[0-9]+\.[0-9]+' ${WEBR_ROOT}/R/R-VERSION)
#export R_VERSION = $(cat $(WEBR_ROOT)/R/R-VERSION)
export R_VERSION=$R_VERSION_SHORT
STARTDIR="$(pwd)"
cd /opt/webr-repo

# For the GitHub Action
if [ "$SOURCEPKG" ]; then
	$R_HOST/bin/R -e "pak::pkg_install('${STARTDIR}/${SOURCEPKG}')"
	PATH="${WEBR_ROOT}/wasm/bin:${PATH}" PKG_CONFIG_PATH="${WEBR_ROOT}/wasm/lib/pkgconfig" ./webr-build.sh "${STARTDIR}/${SOURCEPKG}"
	BINARYPKG=${SOURCEPKG/.tar.gz/.tgz}
	cp "repo/bin/emscripten/contrib/${R_VERSION}/${BINARYPKG}" $STARTDIR/
	echo "binarypkg=$BINARYPKG" >> $GITHUB_OUTPUT
	exit 0
fi

# Not the action
if ! compgen -G "/sources/*.tar.gz" > /dev/null; then
	echo 'No source packages found in /sources/*.tar.gz"sources'
	echo 'Please map the /sources directory docker using for example: -v $(pwd):/sources'
	exit 1
fi
for SOURCEPKG in /sources/*.tar.gz; do
	$R_HOST/bin/R -e "pak::pkg_install('${SOURCEPKG}')"
	PATH="${WEBR_ROOT}/wasm/bin:${PATH}" PKG_CONFIG_PATH="${WEBR_ROOT}/wasm/lib/pkgconfig" ./webr-build.sh $SOURCEPKG
done
cp -Rfv repo /sources/
