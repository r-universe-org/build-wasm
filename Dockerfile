FROM ghcr.io/r-wasm/webr:main

# Add some new unmerged libs
# RUN (cd /opt/webr/libs; git pull https://github.com/jeroen/webr; make libgit2 libarchive gsl glpk mpfr; rm -rf download build )

# Upstream installs nodejs to build webr, but it conflicts with libnode-dev
#RUN rm /etc/apt/sources.list.d/nodesource.list && \
#	apt-get update && \
#	apt-get install -y lsb-release && \
#	apt-get remove -y nodejs && \
#	apt-get autoremove --purge && \
#	apt-get clean all


# Alternative workaround for libnode-dev conflicting with nodejs (see above)
RUN apt-get update && \
	apt-get install -y equivs lsb-release &&\
	equivs-control libnode-dev && \
	sed -i 's/Package:.*/Package: libnode-dev/' libnode-dev && \
	sed -i 's/# Provides:.*/Provides: libv8-dev/' libnode-dev && \
	sed -i 's/# Replaces:.*/Replaces: libv8-dev/' libnode-dev && \
	sed -i 's/# Version:.*/Version: 99.0/' libnode-dev && \
	equivs-build libnode-dev && \
	dpkg -i libnode-dev_99.0_all.deb

# Setup Node, Emscripten & webR
ENV PATH /opt/emsdk:/opt/emsdk/upstream/emscripten:$PATH
ENV EMSDK /opt/emsdk
ENV WEBR_ROOT /opt/webr

ENV R_LIBS_USER=/opt/R/current/lib/R/site-library

# Set CRAN repo
COPY Renviron /opt/R/current/lib/R/etc/Renviron.site
COPY Rprofile /opt/R/current/lib/R/etc/Rprofile.site

# Install pak (and test load it)
RUN R -e 'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$pkgType, R.Version()$os, R.Version()$arch)); library(pak);'

# Install old Matrix that works on R-4.3.0
RUN R -e 'install.packages(c("MASS", "Matrix", "remotes"), repos = "https://p3m.dev/cran/__linux__/jammy/2023-08-14")'

# Install build tooling
RUN R -e 'remotes::install_github("r-wasm/rwasm")'

# Set default shell to bash
COPY entrypoint.sh /entrypoint.sh
RUN ln -sf /usr/bin/bash /bin/sh

COPY test.sh /test.sh
#RUN /test.sh

# Build packages
ENTRYPOINT /entrypoint.sh
