#!/bin/bash
set -e

R -e "download.packages(c('tomledit', 'RcppArmadillo','sf','openssl', 'fftw', 'jsonlite', 'png', 'gdtools', 'ragg', 'systemfonts', 'textshaping', 'gam'),
  '.', repos = 'https://cloud.r-project.org')"
#curl -OL "https://r-rust.r-universe.dev/src/contrib/hellorust_1.2.3.tar.gz"
for pkg in *.tar.gz; do
#broken in pak: R -e "pak::pak('deps::$pkg')"
R -e "pak::pak('./$pkg')"
R -e "rwasm::build('./$pkg')"
done
