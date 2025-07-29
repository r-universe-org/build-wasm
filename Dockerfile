FROM ghcr.io/r-wasm/webr:main

#RUN git config --global pull.rebase true &&\
#	(cd /opt/webr/libs; git pull https://github.com/r-wasm/webr proxy-websockets; make curl; rm -rf download build)

# Alternative workaround
RUN apt-get update && apt-get install -y lsb-release language-pack-en-base

# Install some common runtime libs
RUN CRANLIBS=$(curl https://r-universe.dev/stats/sysdeps/noble | jq --slurp -r '.[].packages | flatten[]' | grep -v "libnode") &&\
	apt-get install -y --no-install-recommends zstd xvfb $CRANLIBS && \
	apt-get clean all

# Set CRAN repo, etc
RUN \
	git clone https://github.com/r-universe-org/base-image &&\
	cp base-image/Rprofile /opt/R/current/lib/R/etc/Rprofile.site &&\
	rm -R base-image

# Update to latest pak
RUN R -e 'install.packages("pak", lib = .Library, repos = "https://r-lib.github.io/p/pak/devel/source/linux-gnu/x86_64")'

# Add cargo shim
COPY shims /shims
RUN cp -v /shims/* "$(R RHOME)/library/rwasm/bin/"

# Set default shell to bash
RUN ln -sf /usr/bin/bash /bin/sh

COPY test.sh /test.sh
