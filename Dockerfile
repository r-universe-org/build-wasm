ARG WEBR_VERSION=v0.2.0-rc.0
FROM georgestagg/webr-build:${WEBR_VERSION}

RUN apt-get update && apt-get install -y lsb-release && apt-get clean all

# Setup Node, Emscripten & webR
ENV PATH /opt/emsdk:/opt/emsdk/upstream/emscripten:$PATH
ENV EMSDK /opt/emsdk
ENV NVM_DIR /opt/nvm
ENV WEBR_ROOT /opt/webr

# Set CRAN repo
COPY Rprofile /opt/webr/host/R-4.3.0/lib/R/etc/Rprofile.site
COPY Renviron /opt/webr/host/R-4.3.0/lib/R/etc/Renviron.site

# Install pak (and test load it)
RUN ${WEBR_ROOT}/host/R-$(cat ${WEBR_ROOT}/R/R-VERSION)/bin/R \
  -e 'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$pkgType, R.Version()$os, R.Version()$arch)); library(pak);'

# Install old Matrix that works on R-4.3.0
RUN ${WEBR_ROOT}/host/R-$(cat ${WEBR_ROOT}/R/R-VERSION)/bin/R \
  -e 'install.packages("MASS"); pak::pkg_install("r-wasm/Matrix@webr-matrix-1.6-0")'

# Copy webr-repo scripts
#COPY scripts /opt/webr-repo
RUN git clone https://github.com/r-wasm/webr-repo /opt/webr-repo

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x ${NVM_DIR}/nvm.sh

# Build packages
ENTRYPOINT /entrypoint.sh
