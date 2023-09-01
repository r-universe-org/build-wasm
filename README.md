# Minimal wasm build image

Simplified docker image to cross-compile R source packages into webassembly.


## How to use

You don't need this repository, everything is in the docker image.

Simply run the container while mapping the host directory containing the R source package(s) to `/sources`. For example to build source packages in your current working directory (pwd):

```sh
# Download a source package on the host
# R -e 'download.packages("rlang", ".", repos = "https://cloud.r-project.org")'

# Build the wasm binaries
docker run --rm -it -v $(pwd):/sources ghcr.io/r-universe-org/build-wasm
```

Afterwards a new subdirectory `repo` is created under the sourced directory containing the wasm binaries.


## How it works

The container actually installs the package twice:

 1. First it installs the package and its dependencies as usual in the default host version of R. This is mostly to trick R to think dependencies are installed. To speed this up, we use pak and ppm binaries.
 2. Then it cross-compiles the source package using emscripten compilers. It does not actually install build the dependencies for emscripten, and the package is installed with `--no-test-load` because it cannot actually be loaded outside of wasm.

