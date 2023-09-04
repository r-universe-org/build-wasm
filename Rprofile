# Enable CRAN and BIOC
options(repos = c(CRAN = "https://cloud.r-project.org"))
utils::setRepositories(ind = 1:4)

local({
  # Enable RSPM
  rver <- getRversion()
  distro <- system2('lsb_release', '-sc', stdout = TRUE)
  options(HTTPUserAgent = sprintf("R/%s R (%s)", rver, paste(rver, R.version$platform, R.version$arch, R.version$os)))
  options(repos = c(P3M = sprintf("https://packagemanager.posit.co/all/__linux__/%s/latest", distro), getOption("repos")))

  # Enable universe repo(s)
  my_universe <- Sys.getenv("MY_UNIVERSE")
  if(nchar(my_universe)){
    my_repos <- trimws(strsplit(my_universe, ';')[[1]])
    binaries <- sprintf('%s/bin/linux/%s/%s', my_repos[1], distro, substr(rver, 1, 3))
    options(repos = c(binaries = binaries, universe = my_repos, getOption("repos")))
  }
})

#print(options('repos'))
