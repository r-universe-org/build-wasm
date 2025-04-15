FROM ghcr.io/r-wasm/webr:main

# Add some new unmerged libs
# RUN (cd /opt/webr/libs; git pull https://github.com/jeroen/webr nlopt; make nlopt; rm -rf download build )

# Upstream installs nodejs to build webr, but it conflicts with libnode-dev
#RUN rm /etc/apt/sources.list.d/nodesource.list && \
#	apt-get update && \
#	apt-get install -y lsb-release && \
#	apt-get remove -y nodejs && \
#	apt-get autoremove --purge && \
#	apt-get clean all


# Alternative workaround for libnode-dev conflicting with nodejs (see above)
RUN apt-get update && \
	apt-get install -y equivs lsb-release language-pack-en-base


#	equivs-control libnode-dev && \
#	sed -i 's/Package:.*/Package: libnode-dev/' libnode-dev && \
#	sed -i 's/# Provides:.*/Provides: libv8-dev/' libnode-dev && \
#	sed -i 's/# Replaces:.*/Replaces: libv8-dev/' libnode-dev && \
#	sed -i 's/# Version:.*/Version: 99.0/' libnode-dev && \
#	equivs-build libnode-dev && \
#	dpkg -i libnode-dev_99.0_all.deb && \
#	rm -Rf libnode*

# Install some common runtime libs
RUN CRANLIBS=$(curl https://r-universe.dev/stats/sysdeps/noble | jq --slurp -r '.[].packages | flatten[]' | grep -v "libnode") &&\
	apt-get install -y --no-install-recommends zstd xvfb $CRANLIBS && \
	apt-get clean all

# Setup Node, Emscripten & webR
ENV PATH=/opt/emsdk:/opt/emsdk/upstream/emscripten:$PATH
ENV EMSDK=/opt/emsdk
ENV WEBR_ROOT=/opt/webr

ENV R_LIBS_USER=/opt/R/current/lib/R/site-library

# Set CRAN repo
COPY Renviron /opt/R/current/lib/R/etc/Renviron.site
COPY Rprofile /opt/R/current/lib/R/etc/Rprofile.site

# Use devel-pak (until solver hangs are fixed)
#RUN R -e 'install.packages("pak", lib = .Library, repos = "https://r-lib.github.io/p/pak/devel/source/linux-gnu/x86_64")'
RUN R -e 'install.packages("pak", lib = .Library, repos = "https://p3m.dev/cran/__linux__/noble/2025-04-01")'

# Set default shell to bash
COPY entrypoint.sh /entrypoint.sh
RUN ln -sf /usr/bin/bash /bin/sh

COPY test.sh /test.sh
#RUN /test.sh

# Temp workaround for https://github.com/emscripten-core/emscripten/issues/22571
RUN sed -i.bak 's|#define TYPEOF|#define FT_TYPEOF|g' /opt/emsdk/upstream/emscripten/cache/sysroot/include/freetype2/config/ftconfig.h

# Build packages
ENTRYPOINT /entrypoint.sh
