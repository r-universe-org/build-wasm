#!/bin/bash
set -e

R -e "download.packages(c('RcppArmadillo','sf','openssl', 'fftw', 'jsonlite', 'png', 'gdtools'), '.', repos = 'https://cran.r-project.org')"
for pkg in *.tar.gz; do
/entrypoint.sh $pkg
done
