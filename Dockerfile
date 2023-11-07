#FROM ghcr.io/r-wasm/webr:main
FROM ghcr.io/jeroen/webr:main

RUN apt-get update && apt-get install -y lsb-release && apt-get clean all

# Setup Node, Emscripten & webR
ENV PATH /opt/emsdk:/opt/emsdk/upstream/emscripten:$PATH
ENV EMSDK /opt/emsdk
ENV WEBR_ROOT /opt/webr

ENV R_LIBS_USER=/opt/R/current/lib/R/site-library

# Set CRAN repo
COPY Renviron /etc/R/Renviron.site
COPY Rprofile /etc/R/Rprofile.site

# Install pak (and test load it)
RUN R -e 'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$pkgType, R.Version()$os, R.Version()$arch)); library(pak);'

# Install old Matrix that works on R-4.3.0
RUN R -e 'install.packages(c("MASS", "Matrix"), repos = "https://p3m.dev/cran/__linux__/jammy/2023-08-14")'

# Copy webr-repo scripts
RUN git clone https://github.com/r-wasm/webr-repo /opt/webr-repo

COPY entrypoint.sh /entrypoint.sh

# Build packages
ENTRYPOINT /entrypoint.sh
