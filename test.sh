#!/bin/bash
set -e

R -e "download.packages(c('RcppArmadillo','sf','openssl', 'fftw', 'jsonlite'), '.', repos = 'https://cran.r-project.org')"
/entrypoint.sh openssl*.tar.gz
/entrypoint.sh fftw*.tar.gz
/entrypoint.sh RcppArmadillo*.tar.gz
/entrypoint.sh sf*.tar.gz
/entrypoint.sh jsonlite*.tar.gz
