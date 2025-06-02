FROM ghcr.io/r-wasm/webr:main

# Alternative workaround
RUN apt-get update && apt-get install -y lsb-release language-pack-en-base

# Install some common runtime libs
RUN CRANLIBS=$(curl https://r-universe.dev/stats/sysdeps/noble | jq --slurp -r '.[].packages | flatten[]' | grep -v "libnode") &&\
	apt-get install -y --no-install-recommends zstd xvfb $CRANLIBS && \
	apt-get clean all

# Set CRAN repo
COPY Renviron /opt/R/current/lib/R/etc/Renviron.site
COPY Rprofile /opt/R/current/lib/R/etc/Rprofile.site

# Use stable pack now again
RUN R -e 'install.packages("pak", lib = .Library, repos = "https://r-lib.github.io/p/pak/stable/source/linux-gnu/x86_64")'

# Set default shell to bash
RUN ln -sf /usr/bin/bash /bin/sh
COPY test.sh /test.sh
