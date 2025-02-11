local({
  r_branch <- substr(getRversion(), 1, 3)
  distro <- system2('lsb_release', '-sc', stdout = TRUE)
  binary_universe <- function(universe){
    sprintf("%s/bin/linux/%s/%s", universe, distro, r_branch)
  }

  # NB: pak also adds cran and bioconductor automatically when not set already
  cran_version <- Sys.getenv("CRAN_VERSION")
  if(nchar(cran_version)){
    repos <- c(
      CRAN = sprintf("https://p3m.dev/cran/__linux__/%s/%s", distro, cran_version),
      BIOC = binary_universe("https://bioc.r-universe.dev")
    )
  } else {
    repos <- c(
      BIOC = binary_universe("https://bioc.r-universe.dev"),
      PPM = sprintf("https://packagemanager.posit.co/cran/__linux__/%s/latest", distro),
      CRAN = 'https://cloud.r-project.org'
    )
  }

  if(nchar(Sys.getenv("MY_UNIVERSE"))){
    repos <- c(MY_UNIVERSE = binary_universe(Sys.getenv("MY_UNIVERSE")), repos)
  }
  options(
    repos = repos,
    HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os))
  )

  # print(pak::repo_status()[,1:2])
})
