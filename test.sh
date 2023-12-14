#!/bin/bash
set -e

R -e "download.packages(c('RcppArmadillo','sf','openssl', 'fftw', 'jsonlite', 'png', 'gdtools', 'ragg', 'systemfonts', 'textshaping', 'gam'),
 '.', repos = sprintf('https://%s.r-universe.dev', c('jeroen', 'r-lib', 'cran')))"
for pkg in *.tar.gz; do
/entrypoint.sh $pkg
done
