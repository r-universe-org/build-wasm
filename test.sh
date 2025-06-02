#!/bin/bash
set -e

R -e "download.packages(c('RcppArmadillo','sf','openssl', 'fftw', 'jsonlite', 'png', 'gdtools', 'ragg', 'systemfonts', 'textshaping', 'gam'),
  '.', repos = 'https://cloud.r-project.org')"
for pkg in *.tar.gz; do
R -e "pak::pak('deps::$pkg')"
R -e "rwasm::build('./$pkg')"
done
