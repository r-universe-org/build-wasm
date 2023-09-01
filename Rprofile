local({
  options(repos = c(CRAN="https://packagemanager.posit.co/cran/__linux__/jammy/latest"))
  options(HTTPUserAgent = sprintf(
    "R/%s R (%s)",
    getRversion(),
    paste(
      getRversion(),
      R.version["platform"],
      R.version["arch"],
      R.version["os"]
    )
  ))
})
