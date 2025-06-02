#!/bin/bash
set -e

R -e "download.packages(c('RcppArmadillo','sf','openssl', 'fftw', 'jsonlite', 'png', 'gdtools', 'ragg', 'systemfonts', 'textshaping', 'gam'),'.')"
for pkg in *.tar.gz; do
R -e "rwasm::build('./$pkg')"
done
