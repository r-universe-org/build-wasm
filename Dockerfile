FROM ghcr.io/r-wasm/webr:main

RUN git config --global pull.rebase true &&\
	(cd /opt/webr/libs; git pull https://github.com/jeroen/webr testing; rm /opt/webr/wasm/lib/libxml2.a; make libjq libxml2 libxslt protobuf; rm -rf download build)

RUN /opt/R/current/bin/R -q -e 'pak::pak("jeroen/rwasm@cargo-shim", lib = .Library)'

# Alternative workaround
RUN apt-get update && apt-get install -y lsb-release language-pack-en-base

# Install some common runtime libs
RUN CRANLIBS=$(curl https://r-universe.dev/api/sysdeps/noble?stream=1 | jq --slurp -r '.[].packages | flatten[]' | grep -v "libnode") &&\
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
#COPY shims /shims
#RUN cp -v /shims/* "$(R RHOME)/library/rwasm/bin/"

# Set default shell to bash
RUN ln -sf /usr/bin/bash /bin/sh

COPY test.sh /test.sh
