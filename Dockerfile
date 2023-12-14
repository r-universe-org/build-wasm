FROM ghcr.io/r-wasm/webr:main

# Upstream installs nodejs to build webr, but it conflicts with libv8-dev
#RUN rm /etc/apt/sources.list.d/nodesource.list && \
#	apt-get update && \
#	apt-get install -y lsb-release && \
#	apt-get remove -y nodejs && \
#	apt-get autoremove --purge && \
#	apt-get clean all


# Alternative workaround for libv8-dev conflicting with nodejs (see above)
RUN apt-get update && \
	apt-get install -y equivs lsb-release &&\
	equivs-control libv8-dev && \
	sed -i 's/Package:.*/Package: libv8-dev/' libv8-dev && \
	equivs-build libv8-dev && \
	dpkg -i libv8-dev_1.0_all.deb

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
